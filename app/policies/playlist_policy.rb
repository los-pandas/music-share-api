# frozen_string_literal: true

module MusicShare
  # Policy to determine if account can interact with a playlist
  class PlaylistPolicy
    def initialize(account, playlist)
      @account = account
      @playlist = playlist
    end

    def can_view?
      playlist_is_public? || account_is_creator?
    end

    def can_edit?
      account_is_creator?
    end

    def can_delete?
      account_is_creator?
    end

    def can_add_songs_to_playlist?
      account_is_creator?
    end

    def can_delete_songs_from_playlist?
      account_is_creator?
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_add_songs_to_playlist: can_add_songs_to_playlist?,
        can_delete_songs_from_playlist: can_delete_songs_from_playlist?
      }
    end

    private

    def playlist_is_public?
      !@playlist.is_private
    end

    def account_is_creator?
      @playlist.account == @account
    end
  end
end
