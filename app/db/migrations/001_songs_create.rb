# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:songs) do
      primary_key :id

      String :title, null: false
      Integer :duration_seconds, null: false
      String :image_url_secure
      String :artists, default: 'Anonymous'

      DateTime :created_at
      DateTime :updated_at

      unique %i[title artists]
    end
  end
end
