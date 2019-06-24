# frozen_string_literal: true

module MusicShare
  # Add a shared acoount to another owner's existing playlist
  class AddSharedAccount
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as a shared account'
      end
    end

    def self.call(auth:, playlist:, shared_email:)
      invitee = Account.first(email: shared_email)
      policy = SharedAccountRequestPolicy.new(
        playlist, auth[:account], invitee, auth[:scope]
      )
      raise ForbiddenError unless policy.can_invite?

      playlist.add_shared_account(invitee)
      invitee
    end
  end
end
