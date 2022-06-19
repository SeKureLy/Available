# frozen_string_literal: true

require_relative './app'

module Available
  # Web controller for Available API
  class Api < Roda
    route('events') do |routing|
      routing.halt 403, { message: 'Not authorized' }.to_json unless @auth_account

      @doc_route = "#{@api_root}/events"

      # GET api/v1/events/[event_id]
      routing.on String do |event_id|
        @req_event = Event.first(id: event_id)
        routing.get do
          event = GetEventQuery.call(
            auth: @auth, event: @req_event
          )

          { data: event }.to_json
        rescue GetEventQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetEventQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "GET EVENT ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
