# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:events) do
      uuid :id, primary_key: true
      foreign_key :calendar_id, table: :calendars

      String :title_secure
      DateTime :start_time
      DateTime :end_time
      String :description_secure
      Integer :created_by
      Integer :share_id
    end
  end
end
