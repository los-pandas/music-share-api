# frozen_string_literal: true

module MusicShare
  # Policy to determine if an account can view a particular project
  class SharedAccountRequestPolicy
    def initialize(playlist, requestor_account, target_account,
                   auth_scope = nil)
      @playlist = playlist
      @requestor_account = requestor_account
      @target_account = target_account
      @auth_scope = auth_scope
      @requestor = PlaylistPolicy.new(requestor_account, playlist, auth_scope)
      @target = PlaylistPolicy.new(target_account, playlist, auth_scope)
    end

    def can_invite?
      can_write? &&
        (@requestor.can_add_shared_accounts? && @target.can_be_shared_account?)
    end

    private

    def can_write?
      @auth_scope ? @auth_scope.can_write?('playlists') : false
    end
  end
end
