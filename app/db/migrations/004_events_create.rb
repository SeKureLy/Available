# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:events) do
      uuid :id, primary_key: true
      foreign_key :calendar_id, table: :calendars

      String :title_secure
      String :start_time, text: true
      String :end_time, text: true
      String :description_secure, text: true

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
