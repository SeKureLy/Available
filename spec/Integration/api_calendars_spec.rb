# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Calendar Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting calendars' do
    describe 'Getting list of calendars' do
      before do
        @account_data = DATA[:accounts][0]
        account = Available::Account.create(@account_data)
        account.add_owned_calendar(DATA[:calendars][0])
        account.add_owned_calendar(DATA[:calendars][1])
      end

      it 'HAPPY: should get list for authorized account' do
        auth = Available::AuthenticateAccount.call(
          username: @account_data['username'],
          password: @account_data['password']
        )
        header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
        get 'api/v1/calendars'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process for unauthorized account' do
        header 'AUTHORIZATION', 'Bearer bad_token'
        get 'api/v1/calendars'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should be able to get details of a single calendar' do
      existing_calendar = DATA[:calendars][1]
      Available::Calendar.create(existing_calendar)
      id = Available::Calendar.first.id

      get "/api/v1/calendars/#{id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal id
      _(result['data']['attributes']['title']).must_equal existing_calendar['title']
      _(result['data']['attributes']['created_by']).must_equal existing_calendar['created_by']
      _(result['data']['attributes']['share_id']).must_equal existing_calendar['share_id']
    end

    it 'SAD: should return error if unknown calendar requested' do
      get '/api/v1/calendars/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      Available::Calendar.create(title: 'New Calendar')
      Available::Calendar.create(title: 'Newer Calendar')
      get 'api/v1/calendars/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Calendars' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @calendar_data = DATA[:calendars][1]
    end

    it 'HAPPY: should be able to create new calendars' do
      post 'api/v1/calendars', @calendar_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      calendar = Available::Calendar.first

      _(created['id']).must_equal calendar.id
      _(created['title']).must_equal @calendar_data['title']
      _(created['created_by']).must_equal @calendar_data['created_by']
      _(created['share_id']).must_equal @calendar_data['share_id']
    end

    it 'SECURITY: should not create calendar with mass assignment' do
      bad_data = @calendar_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/calendars', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
