# frozen_string_literal: true

require 'roda'
require 'json'

module MusicShare
  # Roda class
  class Api < Roda # rubocop:disable ClassLength
    plugin :halt

    route do |routing| # rubocop:disable BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'MusicShare API up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do # rubocop:disable BlockLength
        routing.on 'accounts' do
          @account_route = "#{@api_root}/accounts"

          routing.on String do |username|
            # GET api/v1/accounts/[username]
            routing.get do
              account = Account.first(username: username)
              account ? account.to_json : raise('Account not found')
            rescue StandardError
              routing.halt 404, { message: error.message }.to_json
            end
          end

          # POST api/v1/accounts
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_account = Account.new(new_data)
            raise('Could not save account') unless new_account.save

            response.status = 201
            response['Location'] = "#{@account_route}/#{new_account.id}"
            { message: 'Account saved', data: new_account }.to_json
          rescue Sequel::MassAssignmentRestriction
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError => e
            puts e.inspect
            routing.halt 500, { message: error.message }.to_json
          end
        end
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
        routing.on 'playlist' do # rubocop:disable BlockLength
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
            account_id = new_data['account_id']
            result = MusicShare::CreatePlaylistForCreator.call(
              account_id: account_id, playlist_data: new_data
            )
            raise('Could not save playlist') if result.nil?

            response.status = 201
            { message: 'Playlist saved', data: result }.to_json
          rescue StandardError => error
            routing.halt 400, { message: error.message }.to_json
          end
        end
        routing.on 'song-playlist' do
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
          rescue StandardError => error
            routing.halt 400, { message: error.message }.to_json
          end
        end
      end
    end
  end
end
