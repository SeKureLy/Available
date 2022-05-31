# frozen_string_literal: true

module Available
    # Policy to determine if an account can view a particular calendar
    class InvolvementRequestPolicy
      def initialize(calendar, requestor_account, target_account)
        @calendar = calendar
        @requestor_account = requestor_account
        @target_account = target_account
        @requestor = CalendarPolicy.new(requestor_account, calendar)
        @target = CalendarPolicy.new(target_account, calendar)
      end
  
      def can_invite?
        @requestor.can_add_members? && @target.can_be_member?
      end
  
      def can_remove?
        @requestor.can_remove_members? && target_is_member?
      end
  
      private
  
      def target_is_member?
        @calendar.members.include?(@target_account)
      end
    end
  end
  