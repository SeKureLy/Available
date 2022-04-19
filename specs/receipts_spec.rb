# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Receipt Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:exchanges].each do |exchange_data|
      Available::Exchange.create(exchange_data)
    end
  end

  it 'HAPPY: should be able to get list of all receipts' do
    exchange = Available::Exchange.first
    DATA[:receipts].each do |receipt|
      exchange.add_receipt(receipt)
    end

    get "api/v1/exchanges/#{exchange.id}/receipts"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single receipt' do
    receipt_data = DATA[:receipts][1]
    exchange = Available::Exchange.first
    receipt = exchange.add_receipt(receipt_data).save

    get "/api/v1/exchanges/#{exchange.id}/receipts/#{receipt.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal receipt.id
    _(result['data']['attributes']['sender']).must_equal receipt_data['sender']
    # _(result['data']['attributes']['sender_sig']).must_equal receipt_data['sender_sig']
    _(result['data']['attributes']['receiver']).must_equal receipt_data['receiver']
    # _(result['data']['attributes']['receiver_sig']).must_equal receipt_data['receiver_sig']
    _(result['data']['attributes']['is_money']).must_equal receipt_data['is_money']
  end

  it 'SAD: should return error if unknown receipt requested' do
    exchange = Available::Exchange.first
    get "/api/v1/exchanges/#{exchange.id}/receipts/foobar"

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new receipts' do
    exchange = Available::Exchange.first
    receipt_data = DATA[:receipts][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "api/v1/exchanges/#{exchange.id}/receipts",
         receipt_data.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    receipt = Available::Receipt.first

    _(created['id']).must_equal receipt.id
    _(created['filename']).must_equal receipt_data['filename']
    _(created['description']).must_equal receipt_data['description']
    _(created['sender']).must_equal receipt_data['sender']
    # _(result['data']['attributes']['sender_sig']).must_equal receipt_data['sender_sig']
    _(created['receiver']).must_equal receipt_data['receiver']
    # _(result['data']['attributes']['receiver_sig']).must_equal receipt_data['receiver_sig']
    _(created['is_money']).must_equal receipt_data['is_money']
  end
end
