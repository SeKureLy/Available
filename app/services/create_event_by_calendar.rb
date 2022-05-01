# frozen_string_literal: true

module Available
  # Service object to create a new event for a calendar
  class CreateEventForCalendar
    def self.call(cal_id:, event_data:)
      Calendar.first(id: cal_id)
              .add_event(event_data)
    end
  end
end
