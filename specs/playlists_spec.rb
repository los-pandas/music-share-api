# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Playlist Handling' do # rubocop:disable BlockLength
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:songs].each do |song_data|
      MusicShare::Song.create(song_data)
    end

    DATA[:playlists].each do |playlist_data|
      MusicShare::Playlist.create(playlist_data)
    end

    playlist1 = MusicShare::Playlist.first
    MusicShare::Song.all.each do |song|
      playlist1.add_song(song)
    end
  end

  it 'HAPPY: should be able to get list of all playlists' do
    get 'api/v1/playlist'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single playlists' do
    playlist = MusicShare::Playlist.first
    get "/api/v1/playlist/#{playlist.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal playlist.id
    _(result['data']['attributes']['title']).must_equal playlist.title
  end

  it 'SAD: should return error if unknown playlist requested' do
    get '/api/v1/playlist/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new empty playlist' do
    playlist_data = DATA[:playlists][0]
    playlist_data['title'] = 'New playlist'

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/playlist',
         playlist_data.to_json, req_header
    _(last_response.status).must_equal 201

    created = JSON.parse(last_response.body)['data']['data']['attributes']

    _(created['title']).must_equal playlist_data['title']
  end

  it 'SAD: should return error if playlist title and creator both exist on \
      another playlist' do
    playlist_data = DATA[:playlists][0]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/playlist',
         playlist_data.to_json, req_header
    _(last_response.status).must_equal 400
  end

  it 'HAPPY: should be able to add song to a playlist' do
    playlist = MusicShare::Playlist.last
    song = MusicShare::Song.first

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/song-playlist',
         { 'playlist_id': playlist.id, 'song_id': song.id }.to_json, req_header
    _(last_response.status).must_equal 201
    created = JSON.parse(last_response.body)['data']
    playlist_updated = MusicShare::Playlist[playlist.id]

    _(created['song_id']).must_equal song.id
    _(created['playlist_id']).must_equal playlist.id
    _(playlist_updated.song.length).must_equal 1
  end

  it 'SAD: should return error if try to add a song that does not exist /
      to a playlist' do
    playlist = MusicShare::Playlist.last

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/song-playlist',
         { 'playlist_id': playlist.id, 'song_id': 'foobar' }.to_json, req_header
    _(last_response.status).must_equal 400
  end
end
