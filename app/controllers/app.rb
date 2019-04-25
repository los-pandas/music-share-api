# frozen_string_literal: true

require 'roda'
require 'json'

module MusicShare
  # Roda class
  class Api < Roda
    plugin :halt

    route do |routing| # rubocop:disable BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'MusicShare API up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do # rubocop:disable BlockLength
        routing.on 'song' do
          routing.get String do |song_id|
            song = Song.where(id: :$find_id)
                       .call(:select, find_id: Integer(song_id)).first
            song ? song.to_json : raise('Song not found')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end

          routing.get do
            output = { data: Song.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, message: 'Could not find songs'
          end

          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_song = Song.new(new_data)
            raise('Could not save song') unless new_song.save

            response.status = 201
            { message: 'Song saved', data: new_song }.to_json
          rescue StandardError => error
            routing.halt 400, { message: error.message }.to_json
          end
        end
        routing.on 'playlist' do
          routing.get String do |playlist_id|
            playlist = Playlist.where(id: :$find_id)
                               .call(:select, find_id: Integer(playlist_id))
                               .first
            playlist ? playlist.to_json : raise('Playlist not found')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end

          routing.get do
            output = { data: Playlist.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, message: 'Could not find playlists'
          end

          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_playlist = Playlist.new(new_data)
            raise('Could not save playlist') unless new_playlist.save

            response.status = 201
            { message: 'Playlist saved', data: new_playlist }.to_json
          rescue StandardError => error
            routing.halt 400, { message: error.message }.to_json
          end
        end
        routing.on 'song-playlist' do
          routing.post do
            data = JSON.parse(routing.body.read)
            playlist_id = data['playlist_id']
            song_id = data['song_id']
            raise('Missing playlist_id or song_id') unless !playlist_id.nil?\
                                                           && !song_id.nil?

            playlist = Playlist.where(id: :$find_id)
                               .call(:select, find_id: Integer(playlist_id))
                               .first
            raise('Playlist not found') if playlist.nil?

            song = Song.where(id: :$find_id)
                       .call(:select, find_id: Integer(song_id)).first
            raise('Song not found') if song.nil?

            playlist.add_song(song)
            response.status = 201
            song_playlist = { playlist_id: playlist_id, song_id: song_id }
            { message: 'Song added to playlist', data: song_playlist }.to_json
          rescue StandardError => error
            routing.halt 400, { message: error.message }.to_json
          end
        end
      end
    end
  end
end
