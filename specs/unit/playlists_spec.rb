# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Playlist Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:playlists].each do |playlist_data|
      MusicShare::Playlist.create(playlist_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    playlist_data = DATA[:playlists][0]
    playlist_data['title'] = 'new title'
    new_playlist = MusicShare::Playlist.create(playlist_data)

    playlist = MusicShare::Playlist.find(id: new_playlist.id)
    _(playlist.title).must_equal new_playlist.title
    _(playlist.description).must_equal new_playlist.description
    _(playlist.image_url).must_equal new_playlist.image_url
    _(playlist.creator).must_equal new_playlist.creator
  end

  it 'SECURITY: should secure sensitive attributes' do
    playlist = MusicShare::Playlist.first
    stored_playlist = app.DB[:playlists].first

    _(stored_playlist[:image_url_secure]).wont_be_nil
    _(stored_playlist[:image_url_secure]).wont_equal playlist.image_url
  end
end
