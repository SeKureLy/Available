# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:groups) do
      primary_key :id
      foreign_key :owner_id, table: :accounts

      String :group_name
      
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
