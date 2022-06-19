# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Event Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = Available::Account.create(@account_data)
    @account.add_owned_calendar(DATA[:calendars][0])
    Available::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting a single event' do
    it 'HAPPY: should be able to get details of a single event' do
      event_data = DATA[:events][0]
      calendar = @account.calendars.first
      event = calendar.add_event(event_data)

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/events/#{event.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']['data']

      _(result['attributes']['id']).must_equal event.id
      _(result['attributes']['title']).must_equal event_data['title']
      _(result['attributes']['start_time']).must_equal event_data['start_time']
      _(result['attributes']['end_time']).must_equal event_data['end_time']
      _(result['attributes']['description']).must_equal event_data['description']
    end

    it 'SAD AUTHORIZATION: should not get details without authorization' do
      event_data = DATA[:events][1]
      calendar = Available::Calendar.first
      event = calendar.add_event(event_data)

      get "/api/v1/events/#{event.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not get details with wrong authorization' do
      event_data = DATA[:events][0]
      calendar = @account.calendars.first
      event = calendar.add_event(event_data)

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/events/#{event.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'SAD: should return error if event does not exist' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/events/foobar'

      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating Events' do
    before do
      @calendar = Available::Calendar.first
      @event_data = DATA[:events][1]
    end

    it 'HAPPY: should be able to create when everything correct' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/calendars/#{@calendar.id}/events", @event_data.to_json
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      event = Available::Event.first

      _(created['id']).must_equal event.id
      _(created['title']).must_equal @event_data['title']
      _(created['start_time']).must_equal @event_data['start_time']
      _(created['end_time']).must_equal @event_data['end_time']
      _(created['description']).must_equal @event_data['description']
    end

    it 'BAD AUTHORIZATION: should not create with incorrect authorization' do
      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      post "api/v1/calendars/#{@calendar.id}/events", @event_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'BAD VULNERABILITY: should not create with mass assignment' do
      bad_data = @event_data.clone
      bad_data['created_at'] = '1900-01-01'
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/calendars/#{@calendar.id}/events", bad_data.to_json

      data = JSON.parse(last_response.body)['data']
      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end
  end
end
