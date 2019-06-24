# frozen_string_literal: true

module MusicShare
  # Policy to determine if account can view a project
  class PlaylistPolicy
    # Scope of project policies
    class AccountScope
      def initialize(current_account)
        @current_account = current_account
        @created = created_playlists
        @public = public_playlists
        @full_scope = all_playlists
        @shared_with_account = playlists_shared_with_account
      end

      def viewable
        @full_scope
      end

      attr_reader :public

      def owned
        @created
      end

      def shared
        @shared_with_account
      end

      private

      def all_playlists
        created_playlists + public_playlists
      end

      def created_playlists
        @current_account.playlists
      end

      def playlists_shared_with_account
        @current_account.shared_playlists
      end

      def public_playlists
        MusicShare::Playlist.reject(&:is_private)
      end
    end
  end
end
