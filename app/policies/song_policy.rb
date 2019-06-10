# frozen_string_literal: true

# Policy to determine if an account can interact with a song
class SongPolicy
  def initialize(account, song)
    @account = account
    @song = song
  end

  def can_view?
    true
  end

  def can_edit?
    false
  end

  def can_delete?
    false
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end
end
