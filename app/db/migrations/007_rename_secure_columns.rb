# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    alter_table(:account_sp_tokens) do
      rename_column :token, :token_secure
      rename_column :refresh_token, :refresh_token_secure
    end
  end
end
