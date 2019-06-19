# frozen_string_literal: true

# Policy to determine if an account can interact with a song
class SongPolicy
  def initialize(account, song, auth_scope = nil)
    @account = account
    @song = song
    @auth_scope = auth_scope
  end

  def can_view?
    can_read? && true
  end

  def can_edit?
    can_write? && false
  end

  def can_delete?
    can_write? && false
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def can_read?
    @auth_scope ? @auth_scope.can_read?('songs') : false
  end

  def can_write?
    @auth_scope ? @auth_scope.can_write?('songs') : false
  end
end
