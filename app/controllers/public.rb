# frozen_string_literal: true

require 'roda'
require_relative './app'

module MusicShare
  class Api < Roda
    route('public') do |routing|
      routing.halt 403, { message: UNAUTH_MSG }.to_json unless @auth_account
      routing.get do
        playlists = PlaylistPolicy::AccountScope.new(@auth_account).public
        JSON.pretty_generate(data: playlists)
      rescue StandardError
        routing.halt 403, message: 'Could not find playlists'
      end
    end
  end
end
