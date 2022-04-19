# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test event Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:calendars].each do |calendar_data|
      Available::Calendar.create(calendar_data)
    end
  end

  it 'HAPPY: should be able to get list of all events' do
    calendar = Available::Calendar.first
    DATA[:events].each do |event|
      calendar.add_event(event)
    end

    get "api/v1/calendars/#{calendar.id}/events"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single event' do
    event_data = DATA[:events][1]
    calendar = Available::Calendar.first
    event = calendar.add_event(event_data).save
    
    get "/api/v1/calendars/#{calendar.id}/events/#{event.id}"
    puts "/api/v1/calendars/#{calendar.id}/events/#{event.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal event.id
    _(result['data']['attributes']['title']).must_equal event_data['title']
    # _(result['data']['attributes']['sender_sig']).must_equal event_data['sender_sig']
    _(result['data']['attributes']['start_time']).must_equal event_data['start_time']
    # _(result['data']['attributes']['receiver_sig']).must_equal event_data['receiver_sig']
    _(result['data']['attributes']['end_time']).must_equal event_data['end_time']
  end

  it 'SAD: should return error if unknown event requested' do
    calendar = Available::Calendar.first
    get "/api/v1/calendars/#{calendar.id}/events/foobar"

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new events' do
    calendar = Available::Calendar.first
    event_data = DATA[:events][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "api/v1/calendars/#{calendar.id}/events",
         event_data.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    event = Available::Event.first

    _(created['id']).must_equal event.id
    _(created['title']).must_equal event_data['title']
    _(created['description']).must_equal event_data['description']
    _(created['start_time']).must_equal event_data['start_time']
    # _(result['data']['attributes']['sender_sig']).must_equal event_data['sender_sig']
    _(created['start_time']).must_equal event_data['start_time']
    # _(result['data']['attributes']['receiver_sig']).must_equal event_data['receiver_sig']
    _(created['end_time']).must_equal event_data['end_time']
  end
end
