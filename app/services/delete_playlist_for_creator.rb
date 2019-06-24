# frozen_string_literal: true

module MusicShare
  # create a playlist for a account
  class DeletePlaylistForCreator
    # Error
    class ForbiddenError < StandardError
      def message
        'You are not allowed to delete this playlist'
      end
    end

    # Error for cannot find a playlist
    class NotFoundError < StandardError
      def message
        'We could not find that playlist'
      end
    end

    def self.call(auth:, playlist_data:)
      playlist_id = Integer(playlist_data['id'])
      playlist = Playlist.where(id: :$find_id)
                         .call(:select, find_id: playlist_id)
                         .first
      raise NotFoundError unless playlist

      policy = PlaylistPolicy.new(auth[:account], playlist, auth[:scope])
      raise ForbiddenError unless policy.can_delete?

      auth[:account].remove_playlist(playlist)
    end
  end
end
