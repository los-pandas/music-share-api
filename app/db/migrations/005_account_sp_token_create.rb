# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:account_sp_tokens) do
      primary_key :id
      foreign_key :account_id, table: :accounts
      String :token, null: false
      String :refresh_token, null: false
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
