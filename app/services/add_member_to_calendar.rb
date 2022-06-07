# frozen_string_literal: true

module Available
  # Add a member to another owner's existing calendar
  class AddMemberToCalendar
    # Error for owner cannot be member
    class ForbiddenError < StandardError
      def message = 'Owner cannot be member of project'
    end

    def self.call(auth:,email:, title:)
      invitee = Account.first(email:)
      calendar = Calendar.first(title:)
      policy = InvolvementRequestPolicy.new(calendar, auth[:account], invitee, auth[:scope])
      raise(ForbiddenError) unless policy.can_invite?

      calendar.add_member(invitee)
      invitee
    end
  end
end
