# frozen_string_literal: true

module Available
    # Policy to determine if an account can view a particular calendar
    class InvolvementRequestPolicy
      def initialize(calendar, requestor_account, target_account, auth_scope = nil)
        @calendar = calendar
        @requestor_account = requestor_account
        @target_account = target_account
        @auth_scope = auth_scope
        @requestor = CalendarPolicy.new(requestor_account, calendar, auth_scope)
        @target = CalendarPolicy.new(target_account, calendar, auth_scope)
      end
  
      def can_invite?
        can_write? &&(@requestor.can_add_members? && @target.can_be_member?)
      end
  
      def can_remove?
        can_write? &&(@requestor.can_remove_members? && target_is_member?)
      end
  
      private

      def can_write?
        @auth_scope ? @auth_scope.can_write?('calendars') : false
      end
  
      def target_is_member?
        @calendar.members.include?(@target_account)
      end
    end
  end
  