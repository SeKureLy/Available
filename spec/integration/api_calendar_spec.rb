# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Calendar Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = Available::Account.create(@account_data)
    @wrong_account = Available::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting calendars' do
    describe 'Getting list of calendars' do
      before do
        @account.add_owned_calendar(DATA[:calendars][0])
        @account.add_owned_calendar(DATA[:calendars][1])
      end

      it 'HAPPY: should get list for authorized account' do
        header 'AUTHORIZATION', auth_header(@account_data)
        get 'api/v1/calendars'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process without authorization' do
        get 'api/v1/calendars'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should be able to get details of a single calendar' do
      calendar = @account.add_owned_calendar(DATA[:calendars][0])

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/calendars/#{calendar.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']['data']
      _(result['attributes']['id']).must_equal calendar.id
      _(result['attributes']['title']).must_equal calendar.title
    end

    it 'SAD: should return error if unknown calendar requested' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/calendars/foobar'

      _(last_response.status).must_equal 404
    end

    it 'BAD AUTHORIZATION: should not get calendar with wrong authorization' do
      calendar = @account.add_owned_calendar(DATA[:calendars][0])

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/calendars/#{calendar.id}"
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body
      _(result['attributes']).must_be_nil
    end

    it 'BAD SQL VULNERABILTY: should prevent basic SQL injection of id' do
      @account.add_owned_calendar(DATA[:calendars][0])
      @account.add_owned_calendar(DATA[:calendars][1])

      header 'AUTHORIZATION', auth_header(@account_data)
      get 'api/v1/calendars/2%20or%20id%3E0'

      # deliberately not reporting detection -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Calendars' do
    before do
      @calendar_data = DATA[:calendars][0]
    end

    it 'HAPPY: should be able to create new calendars' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/calendars', @calendar_data.to_json

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      calendar = Available::Calendar.first

      _(created['id']).must_equal calendar.id
      _(created['title']).must_equal @calendar_data['title']
    end

    it 'SAD: should not create new calendar without authorization' do
      post 'api/v1/calendars', @calendar_data.to_json

      created = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(created).must_be_nil
    end

    it 'SECURITY: should not create calendar with mass assignment' do
      bad_data = @calendar_data.clone
      bad_data['created_at'] = '1900-01-01'

      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/calendars', bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
