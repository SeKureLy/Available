# frozen_string_literal: true

module Available
  # Service object to create a new event for a calendar
  class RemoveEventForCalendar
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove the event'
      end
    end

    def self.call(auth:, cal_id:, event_id:)
      calendar = Calendar.first(id: cal_id)
      policy = CalendarPolicy.new(auth[:account], calendar, auth[:scope])
      event = Event.first(id: event_id)
      raise ForbiddenError unless policy.can_remove_events?

      Calendar.first(id: cal_id)
              .remove_event(event)
    end
  end
end
