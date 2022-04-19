# frozen_string_literal: true

require 'json'
require 'sequel'

module Available
  # Holds an event
  class Event < Sequel::Model
    many_to_one :calendar

    plugin :uuid, field: :id
    
    def to_json(options = {})
      JSON(
        { data: {
          type: 'event',
          attributes: {
            id:, title:, start_time:, end_time:, description:, created_by:, share_id:
          }
        }, included: {
          calendar:
        } }, options
      )
    end
  end
end
