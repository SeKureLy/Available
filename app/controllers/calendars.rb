# frozen_string_literal: true

require 'roda'
require_relative './app'

module Available
  # Web controller for Available API
  class Api < Roda
    route('calendars') do |routing|
      @cal_route = "#{@api_root}/calendars"

      routing.on String do |cal_id|
        routing.on 'events' do
          @event_route = "#{@api_root}/calendars/#{cal_id}/events"
          # GET api/v1/calendars/[cal_id]/events/[event_id]
          routing.get String do |event_id|
            event = Event.where(calendar_id: cal_id, id: event_id).first
            event ? event.to_json : raise('Event not found')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end

          # GET api/v1/calendars/[cal_id]/events
          routing.get do
            output = { data: Event.where(calendar_id: cal_id).events }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find events' }.to_json
          end

          # POST api/v1/calendars/[cal_id]/events
          routing.post do
            new_data = JSON.parse(routing.body.read)

            new_event = CreateEventForCalendar.call(
              cal_id:, event_data: new_data
            )

            response.status = 201
            response['Location'] = "#{@event_route}/#{new_event.id}"
            { message: 'Event saved', data: new_event }.to_json

          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.warn "MASS-ASSIGNMENT: #{e.message}"
            routing.halt 500, { message: 'Error creating event' }.to_json
          end
        end

        # GET api/v1/calendars/[cal_id]
        routing.get do
          cal = Calendar.first(id: cal_id)
          cal ? cal.to_json : raise('Calendar not found')
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end

      # GET api/v1/calendars
      routing.get do
        calendars = GetOwnCalendar(@auth_account['username'])
        JSON.pretty_generate(data: calendars)
      rescue StandardError
        routing.halt 403, { message: 'Could not find any calendars' }.to_json
      end

      # POST api/v1/calendars
      routing.post do
        new_data = JSON.parse(routing.body.read)
        owner_id = Account.first(username: @auth_account['username']).owner_id
        CreateCalendarForOwner(owner_id, new_data)
        
        response.status = 201
        response['Location'] = "#{@cal_route}/#{new_cal.id}"
        { message: 'Calendar saved', data: new_cal }.to_json
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
        routing.halt 400, { message: 'Illegal Attributes' }.to_json
      rescue StandardError => e
        Api.logger.error "UNKOWN ERROR: #{e.message}"
        routing.halt 500, { message: 'Unknown server error' }.to_json
      end
    end
  end
end
