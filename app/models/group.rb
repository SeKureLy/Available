# frozen_string_literal: true

require 'json'
require 'sequel'

module Available
  # Models a group
  class Group < Sequel::Model
    many_to_one :owner, class: :'Available::Account'

    many_to_many :members,
                 class: :'Available::Account',
                 join_table: :accounts_groups,
                 left_key: :group_id, right_key: :member_id

    plugin :association_dependencies,
           members: :nullify

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :group_name

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'group',
            attributes: {
              id:,
              group_name:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
