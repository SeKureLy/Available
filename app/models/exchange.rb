# frozen_string_literal: true

require 'json'
require 'sequel'

module AIS
  # Holds a full secret receipt
  class Exchange < Sequel::Model
    one_to_many :receipt

    plugin :timestamps

    def to_json(options = {})
      JSON(
        { type: 'exchange',
          id: id,
          receipt_id: receipt_id
        }, options
      )
    end
  end
end