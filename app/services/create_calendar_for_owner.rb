# frozen_string_literal: true

module Available
  # Service object to create a new calendar for an owner
  class CreateCalendarForOwner
    def self.call(username:, calendar_data:)
      account = Account.first(username:)
      raise('Could not save calendar') unless account.add_owned_calendar(calendar_data)

      Calendar.first(title: calendar_data['title'])
    end
  end
end
