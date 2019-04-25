# frozen_string_literal: true

require 'json'
require 'sequel'

module MusicShare
  # Song class
  class Playlist < Sequel::Model
    many_to_many :song

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :title, :description, :image_url, :creator, :is_private

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
