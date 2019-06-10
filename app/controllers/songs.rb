# frozen_string_literal: true

require 'roda'
require_relative './app'

module MusicShare
  # Web controller for Credence API
  class Api < Roda
    route('song') do |routing| # rubocop:disable BlockLength
      unless @auth_account
        routing.halt 403, { message: 'Not authorized' }.to_json
      end

      routing.get String do |song_id|
        song = GetSongQuery.call(
          account: @auth_account, song_id: song_id
        )

        { data: song }.to_json
      rescue GetSongQuery::NotFoundError => e
        routing.halt 404, { message: e.message }.to_json
      rescue StandardError => e
        puts "FIND SONG ERROR: #{e.inspect}"
        routing.halt 500, { message: 'API server error' }.to_json
      end

      routing.get do
        output = { data: Song.all }
        JSON.pretty_generate(output)
      rescue StandardError
        puts "GET SONGS ERROR: #{e.inspect}"
        routing.halt 500, { message: 'API server error' }.to_json
      end

      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_song = Song.new(new_data)
        raise('Could not save song') unless new_song.save

        response.status = 201
        { message: 'Song saved', data: new_song }.to_json
      rescue Sequel::MassAssignmentRestriction
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue Sequel::UniqueConstraintViolation
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError => e
        puts "ADD SONG ERROR: #{e.inspect}"
        routing.halt 500, { message: 'API server error' }.to_json
      end
    end
  end
end
