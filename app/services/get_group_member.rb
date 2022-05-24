# frozen_string_literal: true

module Available
  # Service object to create a new group for an owner
  class GetOwnCalendar
    def self.call(group_name:)
      group = Group.first(group_name:)
      group.members
    end
  end
end
