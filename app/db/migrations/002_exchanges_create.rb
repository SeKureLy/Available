# frozen_string_literal: true

require 'sequel'

Sequel.migration do
    change do
        create_table(:exchanges) do
            foreign_key :receipt_id
            
            Integer :id
            DateTime :created_at
            DateTime :updated_at

            unique [:id, :receipt_id]
        end
    end
end