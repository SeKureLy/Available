# frozen_string_literal: true

require 'sequel'

Sequel.migration do
    change do
        create_table(:exchanges) do
            primary_key :id
            
            String :seller
            String :buyer
            String :item
            Integer :amount

            DateTime :created_at
            DateTime :updated_at

            # unique [:id, :receipt_id]
        end
    end
end