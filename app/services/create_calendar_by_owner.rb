# frozen_string_literal: true

module Available
    # Service object to create a new calendar for an owner
    class CreateCalendarForOwner
      def self.call(cal_id:, event_data:)
        new_cal = Calendar.new(new_data)
        raise('Could not save calendar') unless new_cal.save
      end
    end
  end