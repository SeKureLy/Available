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
        { data: {
          type: 'exchange',
          attributes: {
            id:, seller:, buyer:, item:, amount:
          }
        } }, options
      )
    end
  end
end
