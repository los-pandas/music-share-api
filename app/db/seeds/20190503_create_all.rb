# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    wipe_database
    puts 'Seeding accounts, playlists, songs'
    create_accounts
    create_playlists
    create_songs
    add_songs_playlist
  end

  def wipe_database
    wipe_playlists_songs
    MusicShare::Api.DB[:accounts].delete
  end

  def wipe_playlists_songs
    MusicShare::Api.DB[:playlists_songs].delete
    MusicShare::Api.DB[:songs].delete
    MusicShare::Api.DB[:playlists].delete
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/account_seeds.yml")
OWNERS_INFO = YAML.load_file("#{DIR}/account_playlist_seeds.yml")
PLAYLISTS_INFO = YAML.load_file("#{DIR}/playlist_seeds.yml")
SONGS_INFO = YAML.load_file("#{DIR}/song_seeds.yml")
PLAYLIST_SONGS_INFO = YAML.load_file("#{DIR}/playlist_song_seeds.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    MusicShare::Account.create(account_info)
  end
end

def create_playlists # rubocop:disable MethodLength
  OWNERS_INFO.each do |owner|
    account = MusicShare::Account.first(username: owner['username'])
    owner['playlist_title'].each do |playlist_title|
      playlist_data = PLAYLISTS_INFO.find do |playlist|
        playlist['title'] == playlist_title
      end
      MusicShare::CreatePlaylistForCreator.call(
        account_id: account.id, playlist_data: playlist_data
      )
    end
  end
end

def create_songs
  SONGS_INFO.each do |song_info|
    MusicShare::Song.create(song_info)
  end
end

def add_songs_playlist # rubocop:disable MethodLength
  playlist_song_info = PLAYLIST_SONGS_INFO
  playlist_song_info.each do |belongs|
    playlist_id = MusicShare::Playlist.first(title: belongs['playlist_title'])
                                      .id
    belongs['song_title'].each do |song_title|
      song_id = MusicShare::Song.first(title: song_title).id
      MusicShare::AddSongToPlaylist.call(
        playlist_id: playlist_id, song_id: song_id
      )
    end
  end
end
