# frozen_string_literal: true

module Available
  # Add a member to another owner's existing calendar
  class AddMemberToCalendar
    # Error for owner cannot be member
    class OwnerNotMemberError < StandardError
      def message = 'Owner cannot be member of project'
    end

    def self.call(email:, calendar_id:)
      member = Account.first(email:)
      calendar = Calendar.first(id: calendar_id)
      raise(OwnerNotMemberError) if calendar.owner.id == member.id

      calendar.add_member(calendar)
    end
  end
end
