# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:playlists) do
      primary_key :id

      String :title, null: false
      String :description, default: ''
      String :image_url
      String :creator, null: false
      FalseClass :is_private, default: false

      DateTime :created_at
      DateTime :updated_at

      unique %i[title creator]
    end
  end
end
