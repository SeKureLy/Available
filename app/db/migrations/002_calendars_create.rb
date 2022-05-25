# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:calendars) do
      primary_key :id
      foreign_key :owner_id, table: :accounts

      String :title, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
