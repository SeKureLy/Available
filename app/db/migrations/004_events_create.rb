# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:events) do
      uuid :id, primary_key: true
      foreign_key :calendar_id, table: :calendars

      String :title_secure
      Integer :start_time
      Integer :end_time
      String :description_secure

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
