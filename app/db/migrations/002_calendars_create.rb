# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:calendars) do
      primary_key :id

      String :title
      Integer :created_by
      Integer :share_id

      DateTime :created_at
      DateTime :updated_at
    end
  end
end