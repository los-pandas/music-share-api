# frozen_string_literal: true

module MusicShare
  # Add a song to a playlist
  class AddSongToPlaylist
    # Error for oaccount is not allowed to add song to playlist
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add songs to this playlist'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot add a song with those attributes'
      end
    end

    def self.call(auth:, playlist_id:, song_id:)
      check_input(playlist_id, song_id)
      playlist = get_playlist(playlist_id)
      song = get_song(song_id)
      raise IllegalRequestError unless !playlist.nil? && !song.nil?

      policy = PlaylistPolicy.new(auth[:account], playlist, auth[:scope])
      raise ForbiddenError unless policy.can_add_songs_to_playlist?

      playlist.add_song(song)
    end

    def self.get_playlist(playlist_id)
      Playlist.where(id: :$find_id)
              .call(:select, find_id: Integer(playlist_id))
              .first
    end

    def self.get_song(song_id)
      Song.where(id: :$find_id)
          .call(:select, find_id: Integer(song_id)).first
    end

    def self.check_input(playlist_id, song_id)
      raise IllegalRequestError unless playlist_id.is_a?(Integer) &&
                                       song_id.is_a?(Integer)
    end
  end
end
