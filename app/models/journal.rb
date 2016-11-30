class Journal < ActiveRecord::Base
  has_many :papers, inverse_of: :journal
  has_many :tasks, through: :papers, inverse_of: :journal
  has_many :roles, inverse_of: :journal
  has_many :assignments, as: :assigned_to
  has_many :discussion_topics, through: :papers, inverse_of: :journal
  has_many :letter_templates

  has_many :manuscript_manager_templates, dependent: :destroy
  has_many :journal_task_types, inverse_of: :journal, dependent: :destroy

  validates :name, presence: { message: 'Please include a journal name' }
  validates :doi_journal_prefix, presence: { message: 'Please include a DOI Journal Prefix' }
  validates :doi_publisher_prefix, presence: { message: 'Please include a DOI Publisher Prefix' }
  validates :last_doi_issued, presence: { message: 'Please include a Last DOI Issued' }
  validates :doi_journal_prefix, uniqueness: {
    scope: [:doi_publisher_prefix],
    if: proc do |journal|
      journal.doi_journal_prefix.present? && journal.doi_publisher_prefix.present?
    end
  }
  validate :has_valid_doi_information?

  after_create :setup_defaults
  before_destroy :confirm_no_papers, prepend: true

  mount_uploader :logo, LogoUploader

  # rubocop:disable Metrics/LineLength
  has_one :academic_editor_role, -> { where(name: Role::ACADEMIC_EDITOR_ROLE) },
    class_name: 'Role'
  has_one :billing_role, -> { where(name: Role::BILLING_ROLE) },
    class_name: 'Role'
  has_one :creator_role, -> { where(name: Role::CREATOR_ROLE) },
    class_name: 'Role'
  has_one :collaborator_role, -> { where(name: Role::COLLABORATOR_ROLE) },
    class_name: 'Role'
  has_one :cover_editor_role, -> { where(name: Role::COVER_EDITOR_ROLE) },
    class_name: 'Role'
  has_one :discussion_participant_role, -> { where(name: Role::DISCUSSION_PARTICIPANT) },
    class_name: 'Role'
  has_one :freelance_editor_role, -> { where(name: Role::FREELANCE_EDITOR_ROLE) },
    class_name: 'Role'
  has_one :internal_editor_role, -> { where(name: Role::INTERNAL_EDITOR_ROLE) },
    class_name: 'Role'
  has_one :handling_editor_role, -> { where(name: Role::HANDLING_EDITOR_ROLE) },
    class_name: 'Role'
  has_one :production_staff_role, -> { where(name: Role::PRODUCTION_STAFF_ROLE) },
    class_name: 'Role'
  has_one :publishing_services_role, -> { where(name: Role::PUBLISHING_SERVICES_ROLE) },
    class_name: 'Role'
  has_one :reviewer_role, -> { where(name: Role::REVIEWER_ROLE) },
    class_name: 'Role'
  has_one :reviewer_report_owner_role, -> { where(name: Role::REVIEWER_REPORT_OWNER_ROLE) },
    class_name: 'Role'
  has_one :staff_admin_role, -> { where(name: Role::STAFF_ADMIN_ROLE) },
    class_name: 'Role'
  has_one :task_participant_role, -> { where(name: Role::TASK_PARTICIPANT_ROLE) },
    class_name: 'Role'
  has_one :user_role, -> { where(name: Role::USER_ROLE, journal_id: nil) },
    class_name: 'Role'
  # rubocop:enable Metrics/LineLength

  def self.staff_admins_for_papers(papers)
    journals = joins(:papers)
               .where(papers: { id: papers })
    journals.flat_map(&:staff_admins)
  end

  def self.staff_admins_across_all_journals
    all.flat_map(&:staff_admins)
  end

  def staff_admins
    User.with_role(staff_admin_role, assigned_to: self)
  end

  def logo_url
    if logo
      logo.thumbnail.url
    else
      '/images/plos_logo.png'
    end
  end

  def paper_types
    # We ordering by the oldest articles first to have 'Research Article'
    # to float to the top of the article drop down list
    manuscript_manager_templates.order('id asc').pluck(:paper_type)
  end

  # Try to block other services from directly updating last_doi_issued to avoid
  # issues where last_doi_issued gets out-of-sync.
  # instead those services should call #next_doi_number!
  def last_doi_issued=(*args)
    return unless new_record?
    super(*args)
  end

  def next_doi_number!
    with_lock do
      last_doi_issued.succ.tap do |next_number|
        update_column :last_doi_issued, next_number
      end
    end
  end

  private

  def has_valid_doi_information?
    ds = DoiService.new(journal: self)
    return unless ds.journal_has_doi_prefixes?
    return if ds.journal_doi_info_valid?
    errors.add(:doi, "The DOI you specified is not valid.")
  end

  def setup_defaults
    # TODO: remove these from being a callback (when we aren't using rails_admin)
    JournalServices::CreateDefaultTaskTypes.call(self)
    JournalServices::CreateDefaultManuscriptManagerTemplates.call(self)
  end

  def confirm_no_papers
    if papers.any?
      message = "journal has #{papers.count} associated papers that must be destroyed first"
      errors.add(:base, message)
      false # prevent destruction
    end
  end
end
