# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module Available
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_groups class: :'Available::Group', key: :owner_id
    many_to_many :members,
                 class: :'Available::Group',
                 join_table: :accounts_groups,
                 left_key: :member_id, right_key: :group_id

    plugin :association_dependencies,
           owned_groups: :destroy,
           members: :nullify

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password

    plugin :timestamps, update_on_create: true

    # def projects
    #   owned_projects + collaborations
    # end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = Available::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          id:,
          username:,
          email:
        }, options
      )
    end
  end
end
