# frozen_string_literal: true

require 'sequel'

Sequel.migration do
    change do
        create_table(:exchanges) do
            primary_key :id
            # foreign_key :receipt_id
            Integer :r1
            Integer :r2
            DateTime :created_at
            DateTime :updated_at

            # unique [:id, :receipt_id]
        end
    end
end