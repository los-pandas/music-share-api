# frozen_string_literal: true

require 'roda'
require_relative './app'

module MusicShare
  # Web controller for Credence API
  class Api < Roda
    route('song-playlist') do |routing|
      routing.post do
        data = JSON.parse(routing.body.read)
        playlist_id = data['playlist_id']
        song_id = data['song_id']
        result = MusicShare::AddSongToPlaylist.call(
          playlist_id: playlist_id, song_id: song_id
        )
        raise('Could not add song to playlist') unless result

        response.status = 201
        song_playlist = { playlist_id: playlist_id, song_id: song_id }
        { message: 'Song added to playlist', data: song_playlist }.to_json
      rescue StandardError => e
        routing.halt 400, { message: e.message }.to_json
      end
    end
  end
end
