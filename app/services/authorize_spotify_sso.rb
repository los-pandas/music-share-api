# frozen_string_literal: true

require 'http'

module MusicShare
  # Find or create an SsoAccount based on spotify code
  class AuthorizeSpotifySso
    def initialize(config)
      @config = config
    end

    def call(token, refresh_token)
      spotify_account = get_spotify_account(token, refresh_token)
      sso_account = find_or_create_sso_account(spotify_account)

      account_and_token(sso_account)
    end

    def get_spotify_account(token, refresh_token)
      sp_response = HTTP.headers(user_agent: 'Config Secure',
                                 authorization: "Bearer #{token}",
                                 accept: 'application/json')
                        .get(@config.SPOTIFY_ACCOUNT_URL)
      raise unless sp_response.status == 200

      account = SpotifyAccount.new(sp_response.parse)
      { username: account.username, email: account.email,
        token: token, refresh_token: refresh_token }
    end

    def find_or_create_sso_account(account_data)
      account = Account.first(email: account_data[:email])
      token_data = { token: account_data[:token],
                     refresh_token: account_data[:refresh_token] }
      if account.nil?
        puts 'created user and tokens'
        account = Account.create_spotify_account(account_data)
      else
        account_sp_token = AccountSPToken.first(account_id: account.id)
        if account_sp_token.nil?
          puts 'created tokens for existing user'
          account.account_sp_token = AccountSPToken.create(token_data)
        else
          puts 'Updated tokens for existing user'
          account_sp_token.update(token: token_data[:token],
                                  refresh_token: token_data[:refresh_token])
        end
      end
      account
    end

    def account_and_token(account)
      {
        type: 'sso_account',
        attributes: {
          account: account,
          auth_token: AuthToken.create(account)
        }
      }
    end

    # Maps spotify account details to attributes
    class SpotifyAccount
      def initialize(sp_account)
        @sp_account = sp_account
      end

      def username
        @sp_account['uri']
      end

      def email
        @sp_account['email']
      end
    end
  end
end
