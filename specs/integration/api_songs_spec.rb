# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Song Handling' do # rubocop:disable BlockLength
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:songs].each do |song_data|
      MusicShare::Song.create(song_data)
    end

    DATA[:accounts].each do |account_data|
      MusicShare::Account.create(account_data)
    end

    @req_header = { 'CONTENT_TYPE' => 'application/json' }
    @account_data = DATA[:accounts][0]
  end

  it 'HAPPY: should be able to get list of all songs' do
    auth = authenticate(@account_data)

    header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
    get '/api/v1/song'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 3
  end

  it 'HAPPY: should be able to get details of a single song' do
    song = MusicShare::Song.first
    auth = authenticate(@account_data)

    header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
    get "api/v1/song/#{song.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse(last_response.body)['data']
    _(result['attributes']['id']).must_equal song.id
    _(result['attributes']['title']).must_equal song.title
  end

  it 'SAD: should return error if unknown song requested' do
    auth = authenticate(@account_data)

    header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
    get '/api/v1/song/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new song' do
    song_data = DATA[:songs][0]
    song_data['title'] = 'new song 1'
    song_data['external_url'] = 'new_url'
    song_data['external_id'] = 'new_id'
    auth = authenticate(@account_data)

    header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
    post 'api/v1/song',
         song_data.to_json, @req_header
    _(last_response.status).must_equal 201
    # _(last_response.header['Location'].size).must_be :>, 0
    created = JSON.parse(last_response.body)['data']['attributes']
    # puts "Created #{created}"
    _(created['title']).must_equal song_data['title']
  end

  it 'SAD: should return error if song title and artist both exist on another \
      song' do
    song_data = DATA[:songs][0]
    auth = authenticate(@account_data)

    header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
    post 'api/v1/song',
         song_data.to_json, @req_header
    _(last_response.status).must_equal 400
  end

  it 'BAD MASS_ASSIGNMENT: should not create songs with mass assignment' do
    bad_data = DATA[:songs][0].clone
    bad_data['title'] = 'Dive'
    bad_data['created_at'] = '1900-01-01'
    auth = authenticate(@account_data)

    header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
    post 'api/v1/song',
         bad_data.to_json, @req_header

    _(last_response.status).must_equal 400
    _(last_response.header['Location']).must_be_nil
  end

  it 'BAD SQL_INJECTION: should prevent basic SQL injection targeting IDs' do
    new_song = MusicShare::Song.create(title: 'New Song', duration_seconds: 120,
                                       image_url: '', artists: 'new artist',
                                       external_url: 'new_external_url',
                                       external_id: 'new_external_id')
    auth = authenticate(@account_data)

    header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
    get "api/v1/song/#{new_song.id}%20or%20id%3E0"

    # deliberately not reporting error -- don't give attacker information
    _(last_response.status).must_equal 404
    _(last_response.body['data']).must_be_nil
  end
end
