# frozen_string_literal: true

require 'json'
require 'sequel'

module Available
  # Holds a full secret receipt
  class Exchange < Sequel::Model
    one_to_many :receipts
    plugin :association_dependencies, receipts: :destroy

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
