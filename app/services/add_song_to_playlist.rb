# frozen_string_literal: true

module MusicShare
  # Add a song to a playlist
  class AddSongToPlaylist
    def self.call(playlist_id:, song_id:)
      return false unless !playlist_id.nil? && !song_id.nil?

      playlist = playlist(playlist_id)
      song = song(song_id)
      return false unless !playlist.nil? && !song.nil?

      playlist.add_song(song)
      true
    end

    def self.playlist(playlist_id)
      Playlist.where(id: :$find_id)
              .call(:select, find_id: Integer(playlist_id))
              .first
    end

    def self.song(song_id)
      Song.where(id: :$find_id)
          .call(:select, find_id: Integer(song_id)).first
    end
  end
end
