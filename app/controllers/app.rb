# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/receipt'

module AIS
  # Web controller for Credence API
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      Receipt.setup
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'CredenceAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'receipts' do
            # GET api/v1/receipts/[id]
            routing.get String do |id|
              Receipt.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Receipt not found' }.to_json
            end

            # GET api/v1/receipts
            routing.get do
              output = { receipt_ids: Receipt.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/receipts
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_receipt = Receipt.new(new_data)

              if new_receipt.save
                response.status = 201
                { message: 'receipt saved', id: new_receipt.id }.to_json
              else
                routing.halt 400, { message: 'Could not save receipt' }.to_json
              end
            end
          end
        end
      end
    end
  end
end
