# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Exchange Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all exchanges' do
    AIS::Exchange.create(DATA[:exchanges][0])
    AIS::Exchange.create(DATA[:exchanges][1])

    get 'api/v1/exchanges'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single exchange' do
    existing_exchange = DATA[:exchanges][1]
    AIS::Exchange.create(existing_exchange)
    id = AIS::Exchange.first.id

    get "/api/v1/exchanges/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal id
    _(result['data']['attributes']['seller']).must_equal existing_exchange['seller']
    _(result['data']['attributes']['buyer']).must_equal existing_exchange['buyer']
    _(result['data']['attributes']['item']).must_equal existing_exchange['item']
    _(result['data']['attributes']['amount']).must_equal existing_exchange['amount']
  end

  it 'SAD: should return error if unknown exchange requested' do
    get '/api/v1/exchanges/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new exchanges' do
    existing_exchange = DATA[:exchanges][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/exchanges', existing_exchange.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    exchange = AIS::Exchange.first

    _(created['id']).must_equal exchange.id
    _(created['seller']).must_equal existing_exchange['seller']
    _(created['buyer']).must_equal existing_exchange['buyer']
    _(created['item']).must_equal existing_exchange['item']
    _(created['amount']).must_equal existing_exchange['amount']
  end
end
