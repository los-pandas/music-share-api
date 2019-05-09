# frozen_string_literal: true

module MusicShare
  # create a playlist for a account
  class CreatePlaylistForCreator
    def self.call(username_data:, playlist_data:)
      playlist_data.delete('username')
      raise('Could not save playlist') if username_data.nil?

      account = Account.where(username: :$find_username)
                       .call(:select, find_username: username_data)
                       .first
      playlist = account.add_playlist(playlist_data)
      playlist
    end
  end
end
