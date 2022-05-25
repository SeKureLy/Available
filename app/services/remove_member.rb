# frozen_string_literal: true

module Available
    # Add a member to another owner's existing calendar
    class RemoveMember
      # Error for owner cannot be member
      class ForbiddenError < StandardError
        def message
          'You are not allowed to remove that person'
        end
      end
  
      def self.call(req_username:, email:, calendar_id:)
        account = Account.first(username: req_username)
        calendar = Calendar.first(id: calendar_id)
        member = Account.first(email:)
  
        policy = InvolvementRequestPolicy.new(calendar, account, member)
        raise ForbiddenError unless policy.can_remove?
  
        calendar.remove_member(member)
        member
      end
    end
  end
  