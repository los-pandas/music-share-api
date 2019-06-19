# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test authentication service' do # rubocop:disable BlockLength
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      MusicShare::Account.create(account_data)
    end
  end

  it 'HAPPY: should authenticate valid account credentials' do
    credentials = DATA[:accounts].first
    account = authenticate(credentials)
    # account = MusicShare::AuthenticateAccount.call(
    #  username: credentials['username'], password: credentials['password']
    # )
    _(account).wont_be_nil
  end

  it 'SAD: will not authenticate with invalid password' do
    credentials = DATA[:accounts].first
    proc {
      credentials['password'] = 'malword'
      authenticate(credentials)
      # MusicShare::AuthenticateAccount.call(
      #  username: credentials['username'], password: 'malword'
      # )
    }.must_raise MusicShare::AuthenticateAccount::UnauthorizedError
  end

  it 'BAD: will not authenticate with invalid credentials' do
    credentials = {}
    proc {
      credentials['username'] = 'maluser'
      credentials['password'] = 'malword'
      authenticate(credentials)
      # MusicShare::AuthenticateAccount.call(
      #  username: 'maluser', password: 'malword'
      # )
    }.must_raise MusicShare::AuthenticateAccount::UnauthorizedError
  end
end
