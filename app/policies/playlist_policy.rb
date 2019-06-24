# frozen_string_literal: true

module MusicShare
  # Policy to determine if account can interact with a playlist
  class PlaylistPolicy
    def initialize(account, playlist, auth_scope = nil)
      @account = account
      @playlist = playlist
      @auth_scope = auth_scope
    end

    def can_view?
      can_read? && (playlist_is_public? || account_is_creator? ||
                    account_is_shared_account?)
    end

    def can_edit?
      can_write? && account_is_creator?
    end

    def can_delete?
      can_write? && account_is_creator?
    end

    def can_add_songs_to_playlist?
      can_write? && account_is_creator?
    end

    def can_delete_songs_from_playlist?
      can_write? && account_is_creator?
    end

    def can_export?
      can_read? && (playlist_is_public? || account_is_creator? ||
                    account_is_shared_account?)
    end

    def can_add_shared_accounts?
      account_is_creator?
    end

    def can_be_shared_account?
      !(account_is_creator? || account_is_shared_account?)
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_add_songs_to_playlist: can_add_songs_to_playlist?,
        can_delete_songs_from_playlist: can_delete_songs_from_playlist?,
        can_export: can_export?,
        can_add_shared_accounts: can_add_shared_accounts?,
        can_be_shared_account: can_be_shared_account?
      }
    end

    private

    def playlist_is_public?
      !@playlist.is_private
    end

    def account_is_creator?
      @playlist.account == @account
    end

    def account_is_shared_account?
      @playlist.shared_accounts.include?(@account)
    end

    def can_read?
      @auth_scope ? @auth_scope.can_read?('playlists') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('playlists') : false
    end
  end
end
