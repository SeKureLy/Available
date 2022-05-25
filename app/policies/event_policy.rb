# frozen_string_literal: true

module Available
    # Policy to determine if account can view a project
    class EventPolicy
        def initialize(account, event)
        @account = account
        @event = event
        end
    
        def can_view?
        account_owns_calendar? || account_involve_in_calendar?
        end
    
        def can_edit?
        account_owns_calendar? || account_involve_in_calendar?
        end
    
        def can_delete?
        account_owns_calendar? || account_involve_in_calendar?
        end
    
        def summary
        {
            can_view: can_view?,
            can_edit: can_edit?,
            can_delete: can_delete?
        }
        end
    
        private
    
        def account_owns_calendar?
        @event.calendar.owner == @account
        end
    
        def account_involve_in_calendar?
        @event.calendar.members.include?(@account)
        end
    end
end