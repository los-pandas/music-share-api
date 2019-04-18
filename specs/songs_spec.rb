# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Song Handling' do # rubocop:disable BlockLength
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:songs].each do |song_data|
      MusicShare::Song.create(song_data)
    end
  end

  it 'HAPPY: should be able to get list of all songs' do
    get '/api/v1/song'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 3
  end

  it 'HAPPY: should be able to get details of a single song' do
    song = MusicShare::Song.first
    get "api/v1/song/#{song.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal song.id
    _(result['data']['attributes']['title']).must_equal song.title
  end

  it 'SAD: should return error if unknown song requested' do
    get '/api/v1/song/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new song' do
    song_data = DATA[:songs][0]
    song_data['title'] = 'Perfect'

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/song',
         song_data.to_json, req_header
    _(last_response.status).must_equal 201
    # _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']

    _(created['title']).must_equal song_data['title']
  end

  it 'SAD: should return error if song title and artist both exist on another \
      song' do
    song_data = DATA[:songs][0]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/song',
         song_data.to_json, req_header
    _(last_response.status).must_equal 400
  end
end
