# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:acl) do
      primary_key :id 

      Integer :share_id, null: false # calender or events
      Integer :type, null: false # user, group
      Integer :target, null: false # user_id, group_id
      Ingeter :start_time
      Ingeter :end_time

      DateTime :created_at
      DateTime :updated_at
    end
  end
end


# event 1
# 1, 1, 'user', 1, 176732988932
# 2, 1, 'group', 3, 176732988932
# 3, 1, 'user', 2, 176732988932
