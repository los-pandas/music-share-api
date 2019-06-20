# frozen_string_literal: true

require 'sequel'
require 'json'

module MusicShare
  # Models a registered accounts token for spotify
  class AccountSPToken < Sequel::Model
    many_to_one :account

    plugin :whitelist_security
    set_allowed_columns :token, :refresh_token

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
