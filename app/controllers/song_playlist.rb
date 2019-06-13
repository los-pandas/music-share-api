# frozen_string_literal: true

require 'roda'
require_relative './app'

module MusicShare
  # Web controller for Credence API
  class Api < Roda
    route('song-playlist') do |routing|
      unless @auth_account
        routing.halt 403, { message: 'Not authorized' }.to_json
      end

      routing.post do
        data = JSON.parse(routing.body.read)
        playlist_id = data['playlist_id']
        song_id = data['song_id']
        MusicShare::AddSongToPlaylist.call(
          account: @auth_account, playlist_id: playlist_id, song_id: song_id
        )
        response.status = 201
        song_playlist = { playlist_id: playlist_id, song_id: song_id }
        { message: 'Song added to playlist', data: song_playlist }.to_json
      rescue AddSongToPlaylist::ForbiddenError => e
        routing.halt 403, { message: e.message }.to_json
      rescue AddSongToPlaylist::IllegalRequestError => e
        routing.halt 400, { message: e.message }.to_json
      rescue StandardError => e
        puts "ADD SONG TO PLAYLIST ERROR: #{e.inspect}"
        routing.halt 500, { message: 'API server error' }.to_json
      end
    end
  end
end
