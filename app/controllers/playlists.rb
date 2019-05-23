# frozen_string_literal: true

require 'roda'
require_relative './app'

module MusicShare
  # Web controller for Credence API
  class Api < Roda
    route('playlist') do |routing| # rubocop:disable BlockLength
      routing.get String do |playlist_id|
        playlist = Playlist.where(id: :$find_id)
                           .call(:select, find_id: Integer(playlist_id))
                           .first
        playlist ? playlist.to_json : raise('Playlist not found')
      rescue StandardError => e
        routing.halt 404, { message: e.message }.to_json
      end

      routing.get do
        account = Account.first(username: @auth_account['username'])
        playlists = account.playlists
        JSON.pretty_generate(data: playlists)
      rescue StandardError
        routing.halt 403, message: 'Could not find playlists'
      end

      routing.post do
        new_data = JSON.parse(routing.body.read)
        username = new_data['username']
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
