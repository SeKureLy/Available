# frozen_string_literal: true

require 'roda'
require_relative './app'

module Available
  # Web controller for Available API
  class Api < Roda
    route('calendars') do |routing|
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      @cal_route = "#{@api_root}/calendars"
      routing.on String do |cal_id|
        @req_calendar = Calendar.first(id: cal_id)

        # GET api/v1/calendars/[ID]
        routing.get do
          calendar = GetCalendarQuery.call(
            account: @auth_account, calendar: @req_calendar
          )

          { data: calendar }.to_json
        rescue GetCalendarQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetCalendarQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND PROJECT ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

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
              account: @auth_account, cal_id:, event_data: new_data
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

        routing.on('members') do
          # PUT api/v1/calendars/[cal_id]/members
          routing.put do
            req_data = JSON.parse(routing.body.read)

            member = AddMemberToCalendar.call(
              account: @auth_account,
              email: req_data['email'],
              title: req_data['title']
            )

            { data: member }.to_json
          rescue AddMemberToCalendar::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end

          # DELETE api/v1/calendars/[cal_id]/members
          routing.delete do
            req_data = JSON.parse(routing.body.read)
            member = RemoveMember.call(
              req_username: @auth_account.username,
              email: req_data['email'],
              calendar_id: cal_id
            )

            { message: "#{member.username} removed from projet",
              data: member }.to_json
          rescue RemoveMember::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
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

      routing .is do
        # GET api/v1/calendars
        routing.get do
          calendars = CalendarPolicy::AccountScope.new(@auth_account).viewable
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
end
