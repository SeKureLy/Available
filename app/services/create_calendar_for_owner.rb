# frozen_string_literal: true

module Available
  # Service object to create a new calendar for an owner
  class CreateCalendarForOwner
    def self.call(owner_id:, calendar_data:)
      account = Account.first(id: owner_id)
      raise('Could not save calendar') unless account.add_owned_calendar(calendar_data)
    end
  end
end