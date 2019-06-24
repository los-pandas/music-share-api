# frozen_string_literal: true

module MusicShare
  # create a playlist for a account
  class UpdatePlaylistForCreator
    # Error
    class ForbiddenError < StandardError
      def message
        'You are not allowed to update this playlist'
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
      raise ForbiddenError unless policy.can_edit?

      update_playlist(playlist, playlist_data)
    end

    def self.update_playlist(playlist, playlist_data)
      playlist.update(title: playlist_data['title'] || '',
                      description: playlist_data['description'] || '',
                      image_url: playlist_data['image_url'] || '',
                      is_private: playlist_data['is_private'] || true)
    end
  end
end
