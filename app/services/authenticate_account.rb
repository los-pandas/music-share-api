# frozen_string_literal: true

module MusicShare
  # Error for invalid credentials
  class UnauthorizedError < StandardError
    def initialize(msg = nil)
      @credentials = msg
    end

    def message
      "Invalid Credentials for: #{@credentials[:username]}"
    end
  end

  # Find account and check password
  class AuthenticateAccount
    def self.call(credentials)
      account = Account.where(username: :$find_username)
                       .call(:select, find_username: credentials[:username])
                       .first
      account.password?(credentials[:password]) ? account : raise
    rescue StandardError
      raise UnauthorizedError, credentials
    end
  end
end
