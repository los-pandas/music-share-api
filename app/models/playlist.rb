# frozen_string_literal: true

require 'json'
require 'sequel'

module MusicShare
  # Song class
  class Playlist < Sequel::Model
    many_to_many :song
    many_to_one :account
    many_to_many :shared_accounts,
                 class: :'MusicShare::Account',
                 join_table: :accounts_playlists,
                 left_key: :playlist_id, right_key: :account_shared_id

    plugin :whitelist_security
    set_allowed_columns :title, :description, :image_url, :is_private
    plugin :timestamps, update_on_create: true
    plugin :association_dependencies, song: :nullify, shared_accounts: :nullify

    # Secure getters and setters
    def image_url
      SecureDB.decrypt(image_url_secure)
    end

    def image_url=(plaintext)
      self.image_url_secure = SecureDB.encrypt(plaintext)
    end

    def summary
      {
        type: 'playlist',
        attributes: {
          id: id,
          title: title,
          description: description,
          image_url: image_url,
          is_private: is_private
        }
      }
    end

    def full_details
      summary.merge(
        relationships: {
          owner: account,
          songs: song,
          shared_accounts: shared_accounts
        }
      )
    end

    def to_json(options = {})
      JSON(summary, options)
    end
  end
end
