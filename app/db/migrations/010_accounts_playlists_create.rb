# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:accounts_playlists) do
      foreign_key :playlist_id, :playlists, key: :id
      foreign_key :account_shared_id, :accounts, key: :id
      primary_key %i[playlist_id account_shared_id]

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
