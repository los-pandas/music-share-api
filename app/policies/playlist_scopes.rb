# frozen_string_literal: true

module MusicShare
  # Policy to determine if account can view a project
  class PlaylistPolicy
    # Scope of project policies
    class AccountScope
      def initialize(current_account)
        @current_account = current_account
        @owned = created_playlists
        @full_scope = all_playlists
      end

      def viewable
        @full_scope
      end

      def owned
        @owned
      end

      private

      def all_playlists
        created_playlists + public_playlists
      end

      def created_playlists
        @current_account.playlists
      end

      def public_playlists
        MusicShare::Playlist.reject { |p| p.is_private }
      end
    end
  end
end
