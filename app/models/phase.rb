class Phase < ActiveRecord::Base
  belongs_to :task_manager, inverse_of: :phases
  has_many :tasks, inverse_of: :phase
  has_many :message_tasks, -> { where(type: 'MessageTask') }, inverse_of: :phase
  acts_as_list scope: :task_manager
  has_one :paper, through: :task_manager

  after_initialize :initialize_defaults

  DEFAULT_PHASE_NAMES = [
    "Submission Data",
    "Assign Editor",
    "Assign Reviewers",
    "Get Reviews",
    "Make Decision"
  ]

  def self.default_phases
    DEFAULT_PHASE_NAMES.map.with_index { |name, pos| Phase.new name: name, position: pos }
  end

  private

  def initialize_defaults
    return if persisted? || tasks.any?
    case name
    when 'Submission Data'
      self.tasks << UploadManuscriptTask.new
      self.tasks << StandardTasks::AuthorsTask.new
      self.tasks << FigureTask.new
      self.tasks << DeclarationTask.new
    when 'Assign Editor'
      self.tasks << PaperAdminTask.new
      self.tasks << StandardTasks::TechCheckTask.new
      self.tasks << PaperEditorTask.new
    when 'Assign Reviewers'
      self.tasks << PaperReviewerTask.new
    when 'Make Decision'
      self.tasks << RegisterDecisionTask.new
    end
  end
end
