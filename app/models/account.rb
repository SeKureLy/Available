# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module Available
  # Models a registered accountvhjrfgyui
  class Account < Sequel::Model
    one_to_many :owned_calendars, class: :'Available::Calendar', key: :owner_id

    many_to_many :involvements,
                class: :'Available::Calendar',
                join_table: :accounts_calendars,
                left_key: :member_id, right_key: :calendar_id

    plugin :association_dependencies,
           owned_calendars: :destroy,
           involvements: :nullify

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password

    plugin :timestamps, update_on_create: true

    def self.create_google_account(google_account)
      create(username: google_account[:username],
             email: google_account[:email])
    end

    def calendars
      owned_calendars + involvements
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = Available::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        { data: {
            type: 'account',
            attributes: {
              username:, 
              email:
            }
        } }, options
      )
    end
  end
end
