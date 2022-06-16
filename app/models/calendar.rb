# frozen_string_literal: true

require 'json'
require 'sequel'

module Available
  # Holds a full secret receipt
  class Calendar < Sequel::Model
    one_to_many :events
    many_to_one :owner, class: :'Available::Account'

    many_to_many :members,
    class: :'Available::Account',
    join_table: :accounts_calendars,
    left_key: :calendar_id, right_key: :member_id

    plugin :association_dependencies,
           events: :destroy,
           members: :nullify

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :title, :type, :guesturl

    # Secure getters and setters
    def guesturl
      SecureDB.decrypt(guesturl_secure)
    end

    def guesturl=(plaintext)
      self.guesturl_secure = SecureDB.encrypt(plaintext)
    end
    
    def to_h
      {
        data: {
          type: 'calendar',
          attributes: {
            id:,
            title:,
            type:,
            guesturl:
          }
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          owner:,
          members:,
          events:
        }
      )
    end

    def full_events
      parse_events = events.map{ |event|
        { data: {
          type: 'event',
          attributes: {
            id:event.id, 
            title:nil, 
            start_time:event.start_time, 
            end_time:event.end_time, 
            description:nil
          }
        }}
      }
      to_h.merge(
        relationships: {
          owner: nil,
          members: nil,
          events: parse_events
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
