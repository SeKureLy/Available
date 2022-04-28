# frozen_string_literal: true

module Available
    # Service object to create a new event for an owner
    class CreateEventForOwner
      def self.call(cal_id:, event_data:)
        Calendar.where(id: cal_id).first
                .add_event(event_data)
      end
    end
  end