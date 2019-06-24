# frozen_string_literal: true

require 'roda'
require_relative './app'

module MusicShare
  # Web controller for MusicShare API
  class Api < Roda
    route('playlist') do |routing| # rubocop:disable BlockLength
      routing.halt 403, { message: UNAUTH_MSG }.to_json unless @auth_account

      routing.on('shared') do
        # PUT api/v1/playlist/shared/[playlist_id]
        routing.put String do |playlist_id|
          req_data = JSON.parse(routing.body.read)
          playlist = Playlist.first(id: playlist_id)
          shared_account = AddSharedAccount.call(
            auth: @auth,
            playlist: playlist,
            shared_email: req_data['email']
          )

          { data: shared_account }.to_json
        rescue AddSharedAccount::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue StandardError => e
          puts e.inspect
          routing.halt 500, { message: 'API server error' }.to_json
        end

        # PUT api/v1/playlist/shared
        routing.get do
          playlists = PlaylistPolicy::AccountScope.new(@auth_account).shared
          JSON.pretty_generate(data: playlists)
        rescue StandardError
          routing.halt 403, message: 'Could not find playlists'
        end
      end

      routing.get String do |playlist_id|
        playlist = GetPlaylistQuery.call(
          auth: @auth, playlist_id: playlist_id
        )

        { data: playlist }.to_json
      rescue GetPlaylistQuery::ForbiddenError => e
        routing.halt 403, { message: e.message }.to_json
      rescue GetPlaylistQuery::NotFoundError => e
        routing.halt 404, { message: e.message }.to_json
      rescue StandardError => e
        puts "FIND PLAYLIST ERROR: #{e.inspect}"
        routing.halt 500, { message: 'API server error' }.to_json
      end

      routing.get do
        playlists = PlaylistPolicy::AccountScope.new(@auth_account).owned
        JSON.pretty_generate(data: playlists)
      rescue StandardError
        routing.halt 403, message: 'Could not find playlists'
      end

      routing.post do
        new_data = JSON.parse(routing.body.read)
        result = MusicShare::CreatePlaylistForCreator.call(
          auth: @auth, playlist_data: new_data
        )
        raise('Could not save playlist') if result.nil?

        response.status = 201
        { message: 'Playlist saved', data: result }.to_json
      rescue CreatePlaylistForCreator::ForbiddenError => e
        routing.halt 403, { message: e.message }.to_json
      rescue StandardError => e
        routing.halt 400, { message: e.message }.to_json
      end

      routing.put String do |playlist_id|
        new_data = JSON.parse(routing.body.read) || {}
        new_data['id'] = playlist_id
        result = MusicShare::UpdatePlaylistForCreator.call(
          auth: @auth, playlist_data: new_data
        )
        raise('Could not update playlist') if result.nil?

        response.status = 200
        { message: 'Playlist updated', data: result }.to_json
      rescue UpdatePlaylistForCreator::ForbiddenError => e
        routing.halt 403, { message: e.message }.to_json
      rescue UpdatePlaylistForCreator::NotFoundError => e
        routing.halt 404, { message: e.message }.to_json
      rescue StandardError => e
        puts e.inspect
        routing.halt 400, { message: e.message }.to_json
      end

      routing.delete String do |playlist_id|
        new_data = {}
        new_data['id'] = playlist_id
        result = MusicShare::DeletePlaylistForCreator.call(
          auth: @auth, playlist_data: new_data
        )
        raise('Could not delete playlist') if result.nil?

        response.status = 200
        { message: 'Playlist deleted', data: result }.to_json
      rescue DeletePlaylistForCreator::ForbiddenError => e
        routing.halt 403, { message: e.message }.to_json
      rescue DeletePlaylistForCreator::NotFoundError => e
        routing.halt 404, { message: e.message }.to_json
      rescue StandardError => e
        puts e.inspect
        routing.halt 400, { message: e.message }.to_json
      end
    end
  end
end
