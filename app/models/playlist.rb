# frozen_string_literal: true

require 'json'
require 'sequel'

module MusicShare
  # Song class
  class Playlist < Sequel::Model
    many_to_many :song
    many_to_one :account

    plugin :whitelist_security
    set_allowed_columns :title, :description, :image_url, :is_private
    plugin :timestamps, update_on_create: true
    plugin :association_dependencies, song: :nullify

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
              account: account,
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
