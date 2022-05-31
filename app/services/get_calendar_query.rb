# frozen_string_literal: true

module Available
  # Service object to create a new group for an owner
  class GetCalendarQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that calendar'
      end
    end

    # Error for cannot find a calendar
    class NotFoundError < StandardError
      def message
        'We could not find that calendar'
      end
    end

    def self.call(account:, calendar:)
      raise NotFoundError unless calendar

      policy = CalendarPolicy.new(account, calendar)
      raise ForbiddenError unless policy.can_view?

      calendar.full_details.merge(policies: policy.summary)
    end
  end
end
