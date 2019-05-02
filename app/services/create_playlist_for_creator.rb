# frozen_string_literal: true

module MusicShare
  # create a playlist for a account
  class CreatePlaylistForCreator
    def self.call(account_id:, playlist_data:)
      new_playlist_data = {}
      new_playlist_data['title'] = playlist_data['title']
      new_playlist_data['description'] = playlist_data['description']
      new_playlist_data['image_url'] = playlist_data['image_url']
      new_playlist_data['is_private'] = playlist_data['is_private']
      account = Account.where(id: :$find_id)
                       .call(:select, find_id: Integer(account_id))
                       .first
      playlist = account.add_playlist(new_playlist_data)
      playlist
    end
  end
end
