# frozen_string_literal: true

require 'roda'
require 'json'

module Available
  # Web controller for Available API
  class Api < Roda
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'Available_API up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'exchanges' do
          @exc_route = "#{@api_root}/exchanges"

          routing.on String do |exc_id|
            routing.on 'receipts' do
              @rec_route = "#{@api_root}/exchanges/#{exc_id}/receipts"
              # GET api/v1/exchanges/[exc_id]/receipts/[rec_id]
              routing.get String do |rec_id|
                rec = Receipt.where(exchange_id: exc_id, id: rec_id).first
                rec ? rec.to_json : raise('Receipts not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/exchanges/[exc_id]/receipts
              routing.get do
                output = { data: Receipt.where(exchange_id: exc_id).all }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, { message: 'Could not find receipts' }.to_json
              end

              # POST api/v1/exchanges/[exc_id]/receipts
              routing.post do
                new_data = JSON.parse(routing.body.read)
                exc = Exchange.where(id: exc_id).first
                new_rec = exc.add_receipt(new_data)
                if new_rec
                  response.status = 201
                  response['Location'] = "#{@rec_route}/#{new_rec.id}"
                  { message: 'Receipt saved', data: new_rec }.to_json
                else
                  routing.halt 400, 'Could not save receipt'
                end

              rescue StandardError
                routing.halt 500, { message: 'Database error' }.to_json
              end
            end

            # GET api/v1/exchanges/[exc_id]
            routing.get do
              exc = Exchange.first
              exc ? exc.to_json : raise('Exchange not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/exchanges
          routing.get do
            output = { data: Exchange.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find exchanges' }.to_json
          end

          # POST api/v1/exchanges
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_exc = Exchange.new(new_data)
            raise('Could not save exchange') unless new_exc.save

            response.status = 201
            response['Location'] = "#{@exc_route}/#{new_exc.id}"
            { message: 'Exchange saved', data: new_exc }.to_json
          rescue StandardError => e
            routing.halt 400, { message: e.message }.to_json
          end
        end
      end
    end
  end
end
