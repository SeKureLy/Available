# frozen_string_literal: true

module Available
    # Policy to determine if account can view a project
    class CalendarPolicy
      # Scope of project policies
      class AccountScope
        def initialize(current_account, target_account = nil)
          target_account ||= current_account
          @full_scope = all_calendars(target_account)
          @current_account = current_account
          @target_account = target_account
        end
  
        def viewable
          if @current_account == @target_account
            @full_scope
          else
            @full_scope.select do |proj|
              includes_member?(proj, @current_account)
            end
          end
        end
  
        private
  
        def all_calendars(account)
          account.owned_calendars + account.involvements
        end
  
        def includes_member?(project, account)
          project.members.include? account
        end
      end
    end
  end
  