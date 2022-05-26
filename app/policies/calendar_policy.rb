# frozen_string_literal: true

module Available
    # Policy to determine if an account can view a particular calendar
    class CalendarPolicy
      def initialize(account, calendar)
        @account = account
        @calendar = calendar
      end
  
      def can_view?
        account_is_owner? || account_is_member?
      end
  
      # duplication is ok!
      def can_edit?
        account_is_owner? || account_is_member?
      end
  
      def can_delete?
        account_is_owner?
      end
  
      def can_leave?
        account_is_member?
      end
  
      def can_add_events?
        account_is_owner? || account_is_member?
      end
  
      def can_remove_events?
        account_is_owner? || account_is_member?
      end
  
      def can_add_members?
        account_is_owner?
      end
  
      def can_remove_members?
        account_is_owner?
      end
  
      # not a owner or member
      def can_be_member?
        not (account_is_owner? or account_is_member?)
      end
  
      def summary
        {
          can_view: can_view?,
          can_edit: can_edit?,
          can_delete: can_delete?,
          can_leave: can_leave?,
          can_add_events: can_add_events?,
          can_delete_documents: can_remove_events?,
          can_add_members: can_add_members?,
          can_remove_members: can_remove_members?,
          can_be_member: can_be_member?
        }
      end
  
      private
  
      def account_is_owner?
        @calendar.owner == @account
      end
  
      def account_is_member?
        @calendar.members.include?(@account)
      end
    end
  end
  