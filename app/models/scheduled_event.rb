# A scheduled event an initiative of the Automated Chasing epic.
#
# At the time of its conceptions, these events are the mechanisms through which
# chasing events are accounted for. This would also serve as contents of a queue
# on which "Eventamatron" would work off to maintain the states of chasing events
class ScheduledEvent < ActiveRecord::Base
  belongs_to :due_datetime

  include AASM

  scope :active, -> { where(state: 'active') }
  scope :inactive, -> { where(state: 'inactive') }
  scope :complete, -> { where(state: 'complete') }

  before_save :deactivate, if: :should_deactivate?
  before_save :reactivate, if: :should_reactivate?

  def should_deactivate?
    dispatch_at && dispatch_at < DateTime.now.in_time_zone && active?
  end

  def should_reactivate?
    dispatch_at && dispatch_at > DateTime.now.in_time_zone && inactive?
  end

  aasm column: :state do
    state :active, initial: true
    state :inactive
    state :complete
    state :error

    event(:reactivate) do
      transitions from: [:complete, :inactive], to: :active
    end

    event(:deactivate) do
      transitions from: :active, to: :inactive
    end

    event(:trigger) do
      transitions from: :active, to: :complete
    end
  end
end