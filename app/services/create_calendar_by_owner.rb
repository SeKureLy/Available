# frozen_string_literal: true

module Available
    # Service object to create a new calendar for an owner
    class CreateCalendarForOwner
      def self.call(owner_id:, calendar_data:)
        Account.first(id: owner_id)
               .add_owned_calendar(calendar_data)
      end
    end
  end