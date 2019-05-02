# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  wipe_playlists_songs
  app.DB[:accounts].delete
end

def wipe_playlists_songs
  app.DB[:playlists_songs].delete
  app.DB[:songs].delete
  app.DB[:playlists].delete
end

song_path = 'app/db/seeds/song_seeds.yml'
playlist_path = 'app/db/seeds/playlist_seeds.yml'
account_path = 'app/db/seeds/account_seeds.yml'
DATA = {} # rubocop:disable Style/MutableConstant
DATA[:songs] = YAML.safe_load File.read(song_path)
DATA[:playlists] = YAML.safe_load File.read(playlist_path)
DATA[:accounts] = YAML.safe_load File.read(account_path)
