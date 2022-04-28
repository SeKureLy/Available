# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(members_id: :accounts, group_id: :groups)
  end
end