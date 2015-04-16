class Decision < ActiveRecord::Base
  belongs_to :paper
  has_many :invitations

  before_validation :increment_revision_number

  default_scope { order('revision_number DESC') }

  validates :revision_number, uniqueness: { scope: :paper_id }

  def self.latest
    first
  end

  def self.pending
    where(verdict: nil)
  end

  def latest?
    self == paper.decisions.latest
  end

  def increment_revision_number
    return if persisted?

    if latest_revision_number = paper.decisions.maximum(:revision_number)
      self.revision_number = latest_revision_number + 1
    end
  end
end
