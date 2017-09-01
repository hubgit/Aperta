# Scheduled Events Worker (Eventamatron)
class ScheduledEventsWorker
  include Sidekiq::Worker

  def perform
    events_to_trigger = ScheduledEvent.due_to_trigger
    events_to_trigger.each do |event|
      event.trigger!
      Activity.reminder_sent!(event)
    end
  end
end