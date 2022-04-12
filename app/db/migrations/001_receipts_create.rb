# frozen_string_literal: true

require 'sequel'

Sequel.migration do
    change do
        create_table(:receipts) do
            primary_key :id
            foreign_key :exchange_id, table: :exchanges

            String :sender
            String :sender_sig
            String :receiver
            String :receiver_sig
            Boolean :IsMoney

            DateTime :created_at
            DateTime :updated_at
        end
    end
end