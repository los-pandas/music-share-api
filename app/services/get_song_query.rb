# frozen_string_literal: true

module MusicShare
  # get access to an account
  class GetSongQuery
    # Error for cannot find a song
    class NotFoundError < StandardError
      def message
        'We could not find that song'
      end
    end

    def self.call(auth:, song_id:)
      song = Song.where(id: :$find_id)
                 .call(:select, find_id: Integer(song_id)).first
      raise NotFoundError unless song

      policy = SongPolicy.new(auth[:account], song, auth[:scope])
      raise ForbiddenError unless policy.can_view?

      song.full_details.merge(policies: policy.summary)
    rescue ArgumentError
      raise NotFoundError
    end
  end
end
