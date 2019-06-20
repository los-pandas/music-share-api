# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    add_column :songs, :external_url, String, unique: true, null: false
  end
end
