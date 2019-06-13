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

def authenticate(account_data)
  credentials = {} # rubocop:disable Style/MutableConstant
  credentials[:username] = account_data['username']
  credentials[:password] = account_data['password']
  MusicShare::AuthenticateAccount.call(credentials)
end

def auth_header(account_data)
  auth = authenticate(account_data)

  "Bearer #{auth[:attributes][:auth_token]}"
end

def authorization(account_data)
  auth = authenticate(account_data)

  contents = AuthToken.contents(auth[:attributes][:auth_token])
  account = contents['payload']['attributes']
  { account: MusicShare::Account.first(username: account['username']),
    scope: AuthScope.new(contents['scope']) }
end

song_path = 'app/db/seeds/song_seeds.yml'
playlist_path = 'app/db/seeds/playlist_seeds.yml'
account_path = 'app/db/seeds/account_seeds.yml'
DATA = {} # rubocop:disable Style/MutableConstant
DATA[:songs] = YAML.safe_load File.read(song_path)
DATA[:playlists] = YAML.safe_load File.read(playlist_path)
DATA[:accounts] = YAML.safe_load File.read(account_path)

## SSO fixtures
GH_ACCOUNT_RESPONSE = YAML.safe_load(
  File.read('specs/fixtures/github_token_response.yml')
)
GOOD_GH_ACCESS_TOKEN = GH_ACCOUNT_RESPONSE.keys.first
SSO_ACCOUNT = YAML.safe_load(File.read('specs/fixtures/sso_account.yml'))
