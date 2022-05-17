# frozen_string_literal: true

require 'json'
require 'sequel'

module Available
  # Holds a full secret receipt
  class Calendar < Sequel::Model
    one_to_many :events
    many_to_one :account

    plugin :association_dependencies,
           events: :destroy

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :title, :share_id

    def to_json(options = {})
      JSON(
        { data: {
          type: 'calendar',
          attributes: {
            id:, title:, owner_id:, share_id:
          }
        } }, options
      )
    end
  end
end
