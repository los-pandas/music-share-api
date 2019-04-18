# frozen_string_literal: true

require 'json'
require 'sequel'

module MusicShare
  # Song class
  class Playlist < Sequel::Model
    many_to_many :song

    plugin :timestamps

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'playlist',
            attributes: {
              id: id,
              title: title,
              description: description,
              image_url: image_url,
              creator: creator,
              is_private: is_private,
              songs: song
            }
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
