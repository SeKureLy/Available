# frozen_string_literal: true

require 'json'
require 'sequel'

module AIS
  # Holds a full secret receipt
  class Calendar < Sequel::Model
    one_to_many :events
    plugin :association_dependencies, events: :destroy

    plugin :timestamps

    def to_json(options = {})
      JSON(
        { data: {
          type: 'calendar',
          attributes: {
            id:, title:, created_by:, share_id:
          }
        } }, options
      )
    end
  end
end
