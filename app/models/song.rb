# frozen_string_literal: true

require 'json'
require 'sequel'

module MusicShare
  # Song class
  class Song < Sequel::Model
    many_to_many :playlist

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :title, :duration_seconds, :image_url, :artists

    # Secure getters and setters
    def image_url
      SecureDB.decrypt(image_url_secure)
    end

    def image_url=(plaintext)
      self.image_url_secure = SecureDB.encrypt(plaintext)
    end

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
