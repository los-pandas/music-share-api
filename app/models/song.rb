# frozen_string_literal: true

require 'json'
require 'sequel'

module MusicShare
  # Song class
  class Song < Sequel::Model
    many_to_many :playlist

    plugin :timestamps

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'song',
            attributes: {
              id: id,
              title: title,
              duration_seconds: duration_seconds,
              image_url: image_url,
              artists: artists
            }
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
