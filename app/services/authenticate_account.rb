# frozen_string_literal: true

module MusicShare
  # Find account and check password
  class AuthenticateAccount
    # Error for invalid credentials
    class UnauthorizedError < StandardError
      def initialize(msg = nil)
        @credentials = msg
      end

      def message
        "Invalid Credentials for: #{@credentials[:username]}"
      end
    end

    def self.call(credentials)
      account = Account.where(username: :$find_username)
                       .call(:select, find_username: credentials[:username])[0]
      unless account.password?(credentials[:password])
        raise(UnauthorizedError, credentials)
      end

      account_and_token(account)
    rescue StandardError
      raise(UnauthorizedError, credentials)
    end

    def self.account_and_token(account)
      {
        type: 'authenticated_account',
        attributes: {
          account: account,
          auth_token: AuthToken.create(account)
        }
      }
    end
  end
end
