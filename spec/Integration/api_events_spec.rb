# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test event Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
    account_data = DATA[:accounts][1]
    @account = Available::Account.create(account_data)
    @account.add_owned_calendar(DATA[:calendars][0])
    credentials = { username: account_data['username'],
                    password: account_data['password'] }
    post 'api/v1/auth/authenticate', credentials.to_json, @req_header
    @auth_token = JSON.parse(last_response.body)['attributes']['auth_token']
  end

  it 'HAPPY: should be able to get list of all events' do
    calendar = Available::Calendar.first
    DATA[:events].each do |event|
      Available::CreateEventForCalendar.call(
        account:@account, cal_id: calendar.id, event_data:event
      )
    end

    header 'AUTHORIZATION', "Bearer #{@auth_token}"
    get "api/v1/calendars/#{calendar.id}/events"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single event' do
    event_data = DATA[:events][1]
    calendar = Available::Calendar.first
    event = Available::CreateEventForCalendar.call(
        account:@account, cal_id: calendar.id, event_data:event_data
    )

    header 'AUTHORIZATION', "Bearer #{@auth_token}"
    get "/api/v1/calendars/#{calendar.id}/events/#{event.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    result = result['data'][0]

    _(result['data']['attributes']['id']).must_equal event.id
    _(result['data']['attributes']['title']).must_equal event_data['title']
    _(result['data']['attributes']['start_time']).must_equal event_data['start_time']
    _(result['data']['attributes']['end_time']).must_equal event_data['end_time']
  end

  it 'SAD: should return error if unknown event requested' do
    calendar = Available::Calendar.first

    header 'AUTHORIZATION', "Bearer #{@auth_token}"
    get "/api/v1/calendars/events/foobar"

    _(last_response.status).must_equal 404
  end

  describe 'Creating Documents' do
    before do
      @calendar = Available::Calendar.first
      @event_data = DATA[:events][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new events' do
      header 'AUTHORIZATION', "Bearer #{@auth_token}"
      post "api/v1/calendars/#{@calendar.id}/events",
           @event_data.to_json, @req_header

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      event = Available::Event.first

      _(created['id']).must_equal event.id
      _(created['title']).must_equal @event_data['title']
      _(created['description']).must_equal @event_data['description']
      _(created['start_time']).must_equal @event_data['start_time']
      _(created['end_time']).must_equal @event_data['end_time']
    end

    it 'SECURITY: should not create documents with mass assignment' do
      bad_data = @event_data.clone
      bad_data['created_at'] = '1900-01-01'

      header 'AUTHORIZATION', "Bearer #{@auth_token}"
      post "api/v1/calendars/#{@calendar.id}/events",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
