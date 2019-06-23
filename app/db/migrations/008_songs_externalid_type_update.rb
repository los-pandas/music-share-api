# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    add_column :songs, :external_id, String, unique: true, null: false
    add_column :songs, :source, String, default: 'spotify'
  end
end
