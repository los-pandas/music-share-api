# frozen_string_literal: true

require 'roda'
require_relative './app'

module MusicShare
  # Web controller for MusicShare API
  class Api < Roda
    route('song-playlist') do |routing| # rubocop:disable BlockLength
      unless @auth_account
        routing.halt 403, { message: 'Not authorized' }.to_json
      end

      routing.post do
        data = JSON.parse(routing.body.read)
        playlist_id = Integer(data['playlist_id'])
        song_data = data['song_data']
        song = Song.find(external_id: song_data['external_id'])
        song_id = song.id unless song.nil?
        song_id = Song.create(song_data).id if song.nil?
        MusicShare::AddSongToPlaylist.call(
          auth: @auth, playlist_id: playlist_id, song_id: song_id
        )
        response.status = 201
        song_playlist = { playlist_id: playlist_id, song_id: song_id }
        { message: 'Song added to playlist', data: song_playlist }.to_json
      rescue AddSongToPlaylist::ForbiddenError => e
        routing.halt 403, { message: e.message }.to_json
      rescue AddSongToPlaylist::IllegalRequestError => e
        routing.halt 400, { message: e.message }.to_json
      rescue Sequel::NotNullConstraintViolation => e
        routing.halt 400, { message: e.message }.to_json
      rescue StandardError => e
        puts "ADD SONG TO PLAYLIST ERROR: #{e.inspect}"
        routing.halt 500, { message: 'API server error' }.to_json
      end
    end
  end
end
