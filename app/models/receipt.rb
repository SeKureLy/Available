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
        { type: 'receipt',
          id: id,
          sender: sender,
          receiver: receiver,
          sender_sig: sender_sig,
          receiver_sig: receiver_sig,
          is_money: is_money }, options
      )
    end
  end
end
