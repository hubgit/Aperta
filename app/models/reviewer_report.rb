# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# This class represents the reviewer reports per decision round
class ReviewerReport < ActiveRecord::Base
  include ViewableModel
  include Answerable
  include AASM

  default_scope { order('decision_id DESC') }

  has_one :due_datetime, as: :due
  has_many :scheduled_events, -> { order :dispatch_at }, through: :due_datetime

  belongs_to :task, foreign_key: :task_id
  belongs_to :user
  belongs_to :decision
  has_one :paper, through: :task
  has_many :admin_edits

  validates :task,
    uniqueness: { scope: [:task_id, :user_id, :decision_id],
                  message: 'Only one report allowed per reviewer per decision' }

  delegate :due_at, :originally_due_at, to: :due_datetime, allow_nil: true

  SCHEDULED_EVENTS_TEMPLATE = [
    { name: 'Pre-due Reminder', dispatch_offset: -2 },
    { name: 'First Late Reminder', dispatch_offset: 2 },
    { name: 'Second Late Reminder', dispatch_offset: 4 }
  ].freeze

  def set_due_datetime(length_of_time: review_duration_period.days)
    DueDatetime.set_for(self, length_of_time: length_of_time)
    schedule_events
  end

  def schedule_events(owner: self, template: SCHEDULED_EVENTS_TEMPLATE)
    ScheduledEventFactory.new(owner, template).schedule_events
  end

  def self.for_invitation(invitation)
    reports = ReviewerReport.where(user: invitation.invitee,
                                   decision: invitation.decision)
    if reports.count > 1
      raise "More than one reviewer report for invitation (#{invitation.id})"
    end
    reports.first
  end

  aasm column: :state do
    state :invitation_not_accepted, initial: true
    state :review_pending
    state :submitted

    event(:accept_invitation,
          after_commit: [:set_due_datetime, :thank_reviewer],
          guards: [:invitation_accepted?]) do
      transitions from: :invitation_not_accepted, to: :review_pending
    end

    event(:rescind_invitation, after: [:cancel_reminders]) do
      transitions from: [:invitation_not_accepted, :review_pending],
                  to: :invitation_not_accepted
    end

    event(:submit,
          guards: [:invitation_accepted?], after: [:set_submitted_at, :thank_reviewer, :cancel_reminders]) do
      transitions from: :review_pending, to: :submitted
    end
  end

  def invitation
    @invitation ||= decision.latest_invitation(invitee_id: user.id)
  end

  def invitation_accepted?
    invitation && invitation.accepted?
  end

  def revision
    # if a decision has a revision, use it, otherwise, use paper's
    major_version = decision.major_version || task.paper.major_version || 0
    minor_version = decision.minor_version || task.paper.minor_version || 0
    "v#{major_version}.#{minor_version}"
  end

  # this is a convenience method that's called by
  # NestedQuestionAnswersController#fetch_answer and a few other places
  def paper
    task.paper
  end

  # overrides Answerable to determine the correct Card that should be
  # assigned when a new ReviewerReport is created
  def default_card
    name = if paper.uses_research_article_reviewer_report
             "ReviewerReport"
           else
             # note: this AR model does not yet exist, but
             # is being done as preparatory / consistency for
             # card config work
             "TahiStandardTasks::FrontMatterReviewerReport"
           end
    Card.find_by(name: name)
  end

  def status
    case aasm.current_state
    when STATE_INVITATION_NOT_ACCEPTED
      compute_invitation_state
    when STATE_REVIEW_PENDING
      "pending"
    when STATE_SUBMITTED
      "completed"
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def datetime
    case status
    when "pending"
      invitation.accepted_at
    when "invitation_invited"
      invitation.invited_at
    when "invitation_accepted"
      invitation.accepted_at
    when "invitation_declined"
      invitation.declined_at
    when "invitation_rescinded"
      invitation.rescinded_at
    when "completed"
      submitted_at
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def display_status
    inactive = ["not_invited", "invitation_declined", "invitation_rescinded"]
    return :minus if inactive.include? status
    return :active_check if status == "completed"
    :check
  end

  def active_admin_edit?
    admin_edits.active.present?
  end

  def cancel_reminders
    scheduled_events.cancelable.each(&:cancel!)
  end

  def user_can_view?(check_user)
    # Yeah, this seems crazy. See the reviewer report controller,
    # which has the same logic. Shawn Gatchell and Erik Hetzner
    # confirm that this behavior is intended, but we do not know the
    # reason for it. Future visitors, feel free to fix this.
    check_user.can?(:edit, task)
  end

  private

  def set_submitted_at
    update!(submitted_at: Time.current.utc)
  end

  def compute_invitation_state
    if invitation
      "invitation_#{invitation.state}"
    else
      "not_invited"
    end
  end

  def review_duration_period
    invitation.due_in || paper.review_duration_period
  end

  def thank_reviewer
    mailer = TahiStandardTasks::ReviewerMailer
    case state
    when 'submitted'
      mailer.delay.thank_reviewer(reviewer_report_id: id)
    when 'review_pending'
      mailer.delay.welcome_reviewer(assignee_id: user.id, paper_id: paper.id)
    end
  end
end
