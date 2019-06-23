# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    add_column :accounts, :display_name, String
  end
end
