# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module MusicShare
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :playlists

    one_to_one :account_sp_token, class: :'MusicShare::AccountSPToken'

    many_to_many :shared_playlists,
                 class: :'MusicShare::Playlist',
                 join_table: :accounts_playlists,
                 left_key: :account_shared_id, right_key: :playlist_id

    plugin :association_dependencies, playlists: :destroy,
                                      account_sp_token: :destroy,
                                      shared_playlists: :nullify

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password, :account_sp_token,
                        :display_name

    plugin :timestamps, update_on_create: true

    def self.create_github_account(github_account)
      create(username: github_account[:username],
             email: github_account[:email],
             display_name: github_account[:display_name])
    end

    def self.create_spotify_account(spotify_account)
      account = create(username: spotify_account[:username],
                       email: spotify_account[:email],
                       display_name: spotify_account[:display_name])
      token_data = { token: spotify_account[:token],
                     refresh_token: spotify_account[:refresh_token] }
      account.account_sp_token = AccountSPToken.create(token_data)
      account
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = MusicShare::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          type: 'account',
          attributes: {
            username: username,
            email: email,
            display_name: display_name
          },
          spotify_token: account_sp_token
        }, options
      )
    end

    def spotify_token_hash
      {
        token: account_sp_token.token,
        refresh_token: account_sp_token.refresh_token
      }
    end
  end
end
