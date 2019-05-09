# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Playlist Handling' do # rubocop:disable BlockLength
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:songs].each do |song_data|
      MusicShare::Song.create(song_data)
    end

    DATA[:accounts].each do |account_data|
      MusicShare::Account.create(account_data)
    end

    account = MusicShare::Account.first
    DATA[:playlists].each do |playlist_data|
      MusicShare::CreatePlaylistForCreator.call(
        username_data: account.username,
        playlist_data: playlist_data
      )
    end

    playlist1 = MusicShare::Playlist.first
    MusicShare::Song.all.each do |song|
      playlist1.add_song(song)
    end
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
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
    playlist_data['title'] = 'new'
    account = MusicShare::Account.first
    playlist_data['username'] = account.username

    post 'api/v1/playlist',
         playlist_data.to_json, @req_header
    _(last_response.status).must_equal 201

    created = JSON.parse(last_response.body)['data']['data']['attributes']

    _(created['title']).must_equal playlist_data['title']
  end

  it 'SAD: should return error if playlist title and creator both exist on \
      another playlist' do
    playlist_data = DATA[:playlists][0]
    account = MusicShare::Account.first
    playlist_data['username'] = account.username
    post 'api/v1/playlist',
         playlist_data.to_json, @req_header
    _(last_response.status).must_equal 400
  end

  it 'HAPPY: should be able to add song to a playlist' do
    playlist = MusicShare::Playlist.last
    song = MusicShare::Song.first

    post 'api/v1/song-playlist',
         { 'playlist_id': playlist.id, 'song_id': song.id }.to_json, @req_header
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

    post 'api/v1/song-playlist',
         { 'playlist_id': playlist.id, 'song_id': 'foobar' }.to_json, \
         @req_header
    _(last_response.status).must_equal 400
  end

  it 'SECURITY: should not create playlists with mass assignment' do
    bad_data = DATA[:playlists][0].clone
    bad_data['title'] = 'Bad Playlist'
    bad_data['created_at'] = '1900-01-01'
    post 'api/v1/playlist',
         bad_data.to_json, @req_header

    _(last_response.status).must_equal 400
    _(last_response.header['Location']).must_be_nil
  end

  it 'SECURITY: should prevent basic SQL injection targeting IDs' do
    account = MusicShare::Account.first
    playlist_data = {}
    playlist_data['title'] = 'New Playlist'
    playlist_data['description'] = ''
    playlist_data['image_url'] = ''
    new_playlist = MusicShare::CreatePlaylistForCreator.call(
      username_data: account.username,
      playlist_data: playlist_data
    )
    get "api/v1/playlist/#{new_playlist.id}%20or%20id%3E0"

    # deliberately not reporting error -- don't give attacker information
    _(last_response.status).must_equal 404
    _(last_response.body['data']).must_be_nil
  end
end
