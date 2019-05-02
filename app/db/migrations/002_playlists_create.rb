# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:playlists) do
      primary_key :id
      foreign_key :account_id, table: :accounts

      String :title, null: false
      String :description, default: ''
      String :image_url_secure
      FalseClass :is_private, default: false

      DateTime :created_at
      DateTime :updated_at

      unique %i[title account_id]
    end
  end
end
