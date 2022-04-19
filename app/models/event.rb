# frozen_string_literal: true

require 'json'
require 'sequel'

module Available
  # Holds an event
  class Event < Sequel::Model
    many_to_one :calendar

    plugin :uuid, field: :id
    plugin :whitelist_security
    set_allowed_columns :title, :start_time, :end_time, :description, :share_id

    # Secure getters and setters
    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def title
      SecureDB.decrypt(title_secure)
    end

    def title=(plaintext)
      self.title_secure = SecureDB.encrypt(plaintext)
    end

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
