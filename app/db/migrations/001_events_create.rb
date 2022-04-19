# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:events) do
      primary_key :uuid
      foreign_key :calendar_id, table: :calendars

      String :title
      DateTime :start_time
      DateTime :end_time
      String :description
      Integer :created_by
      Integer :share_id
    end
  end
end
