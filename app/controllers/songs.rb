# frozen_string_literal: true

require 'roda'
require_relative './app'

module MusicShare
  # Web controller for Credence API
  class Api < Roda
    route('song') do |routing|
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
      rescue StandardError => e
        routing.halt 400, { message: e.message }.to_json
      end
    end
  end
end
