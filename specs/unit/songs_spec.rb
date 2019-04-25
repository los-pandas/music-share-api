# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Song Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:songs].each do |song_data|
      MusicShare::Song.create(song_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    song_data = DATA[:songs][0]
    song_data['title'] = 'new title'
    new_song = MusicShare::Song.create(song_data)

    song = MusicShare::Song.find(id: new_song.id)
    _(song.title).must_equal new_song.title
    _(song.duration_seconds).must_equal new_song.duration_seconds
    _(song.image_url).must_equal new_song.image_url
    _(song.artists).must_equal new_song.artists
  end

  it 'SECURITY: should secure sensitive attributes' do
    song = MusicShare::Song.first
    stored_song = app.DB[:songs].first

    _(stored_song[:image_url_secure]).wont_be_nil
    _(stored_song[:image_url_secure]).wont_equal song.image_url
  end
end
