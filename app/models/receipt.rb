# frozen_string_literal: true

require 'json'
require 'sequel'

module AIS
  # Holds a full secret receipt
  class Receipt < Sequel::Model
    # two receipt form one exchange
    many_to_one :exchange

    plugin :timestamps

    def to_json(options = {})
      JSON(
        { data: {
          type: 'receipt',
          attributes: {
            id:, sender:, receiver:, sender_sig:, receiver_sig:, is_money:
          }
        }, included: {
          exchange:
        } }, options
      )
    end
  end
end
