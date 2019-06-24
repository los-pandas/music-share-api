# frozen_string_literal: true

require 'sequel'
require 'json'

module MusicShare
  # Models a registered accounts token for spotify
  class AccountSPToken < Sequel::Model
    many_to_one :account

    plugin :whitelist_security
    set_allowed_columns :token, :refresh_token

    # Secure getters and setters
    def token
      SecureDB.decrypt(token_secure)
    end

    def token=(plaintext)
      self.token_secure = SecureDB.encrypt(plaintext)
    end

    def refresh_token
      SecureDB.decrypt(refresh_token_secure)
    end

    def refresh_token=(plaintext)
      self.refresh_token_secure = SecureDB.encrypt(plaintext)
    end

    def to_json(options = {})
      JSON(
        {
          token: token,
          refresh_token: refresh_token
        }, options
      )
    end
  end
end
