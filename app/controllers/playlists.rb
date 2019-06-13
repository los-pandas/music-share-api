# frozen_string_literal: true

require 'roda'
require_relative './app'

module MusicShare
  # Web controller for Credence API
  class Api < Roda
    route('playlist') do |routing| # rubocop:disable BlockLength
      unless @auth_account
        routing.halt 403, { message: 'Not authorized' }.to_json
      end

      routing.get String do |playlist_id|
        playlist = GetPlaylistQuery.call(
          account: @auth_account, playlist_id: playlist_id
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
        username = @auth_account.username
        result = MusicShare::CreatePlaylistForCreator.call(
          username_data: username, playlist_data: new_data
        )
        raise('Could not save playlist') if result.nil?

        response.status = 201
        { message: 'Playlist saved', data: result }.to_json
      rescue StandardError => e
        routing.halt 400, { message: e.message }.to_json
      end
    end
  end
end
