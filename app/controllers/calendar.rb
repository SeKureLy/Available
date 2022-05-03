# frozen_string_literal: true

require 'roda'
require_relative './app'

module Available
  # Web controller for Credence API
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
                output = { data: Event.where(calendar_id: cal_id).all }
                JSON.pretty_generate(output)
            rescue StandardError
                routing.halt 404, { message: 'Could not find events' }.to_json
            end

            # POST api/v1/calendars/[cal_id]/events
            routing.post do
                new_data = JSON.parse(routing.body.read)
                cal = Calendar.where(id: cal_id).first
                new_event = cal.add_event(new_data)
                if new_event
                response.status = 201
                response['Location'] = "#{@event_route}/#{new_event.id}"
                { message: 'Event saved', data: new_event }.to_json
                else
                routing.halt 400, 'Could not save event'
                end
            rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
                routing.halt 400, { message: 'Illegal Attributes' }.to_json
            rescue StandardError => e
                routing.halt 500, { message: e.message }.to_json
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
            output = { data: Calendar.all }
            JSON.pretty_generate(output)
        rescue StandardError
            routing.halt 404, { message: 'Could not find calendars' }.to_json
        end

        # POST api/v1/calendars
        routing.post do
            new_data = JSON.parse(routing.body.read)
            new_cal = Calendar.new(new_data)
            raise('Could not save calendar') unless new_cal.save

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
