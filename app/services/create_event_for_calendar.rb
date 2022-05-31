# frozen_string_literal: true

module Available
  # Service object to create a new event for a calendar
  class CreateEventForCalendar
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more events'
      end
    end
    def self.call(auth:, cal_id:, event_data:)
      calendar = Calendar.first(id: cal_id)
      policy = CalendarPolicy.new(auth[:account], calendar, auth[:scope])
      raise ForbiddenError unless policy.can_add_events?
      Calendar.first(id: cal_id)
              .add_event(event_data)
    end
  end
end
