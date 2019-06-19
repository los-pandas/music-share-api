# frozen_string_literal: true

module MusicShare
  # create a playlist for a account
  class CreatePlaylistForCreator
    # Error
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add create more playlists'
      end
    end

    def self.call(auth:, playlist_data:)
      raise ForbiddenError unless auth[:scope].can_write?('playlists')

      auth[:account].add_playlist(playlist_data)
    end
  end
end
