# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Event Handling' do
  before do
    wipe_database

    DATA[:calendars].each do |calendar_data|
      Available::Calendar.create(calendar_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    event_data = DATA[:events][1]
    calender = Available::Calendar.first
    new_event = calender.add_event(event_data)

    event = Available::Event.find(id: new_event.id)
    # _(event.title).must_equal event_data['title']
    _(event.start_time).must_equal event_data['start_time']
    _(event.end_time).must_equal event_data['end_time']
    # _(event.description).must_equal event_data['description']
    # _(event.share_id).must_equal event_data['share_id']
  end

  it 'SECURITY: should not use deterministic integers' do
    event_data = DATA[:events][1]
    calendar = Available::Calendar.first
    new_event = calendar.add_event(event_data)

    _(new_event.id.is_a?(Numeric)).must_equal false
  end

  it 'SECURITY: should secure sensitive attributes' do
    event_data = DATA[:events][1]
    calendar = Available::Calendar.first
    new_event = calendar.add_event(event_data)
    stored_event = app.DB[:events].first

    _(stored_event[:title_secure]).wont_equal new_event.title
    _(stored_event[:description_secure]).wont_equal new_event.description
  end
end
