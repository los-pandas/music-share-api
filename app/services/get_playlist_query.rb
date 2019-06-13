# frozen_string_literal: true

module MusicShare
  # get access to an account
  class GetPlaylistQuery
    # Error for not having access to the playlist
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that playlist'
      end
    end

    # Error for cannot find a playlist
    class NotFoundError < StandardError
      def message
        'We could not find that playlist'
      end
    end

    def self.call(account:, playlist_id:)
      playlist_id = Integer(playlist_id)
      playlist = Playlist.where(id: :$find_id)
                         .call(:select, find_id: playlist_id)
                         .first
      raise NotFoundError unless playlist

      policy = PlaylistPolicy.new(account, playlist)
      raise ForbiddenError unless policy.can_view?

      playlist.full_details.merge(policies: policy.summary)
    rescue ArgumentError
      raise NotFoundError
    end
  end
end
