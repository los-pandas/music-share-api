# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:playlists_songs) do
      foreign_key :playlist_id, :playlists, key: :id
      foreign_key :song_id, :songs, key: :id
      primary_key %i[playlist_id song_id]

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
