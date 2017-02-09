class Admin::EntriesController < ApplicationController
  before_action :restrict_access
  before_action :set_entity, except: [:index]

  # get /admin/entries
  def index
    @collection = Entry.page_for_administration current_page
  end

  # get /admin/entries/:id
  def show
    set_adjacent_entities
  end

  # get /admin/entries/:id/comments
  def comments
    @collection = @entity.comments.page_for_administration(current_page)
  end

  protected

  def restrict_access
    require_role :administrator
  end

  def set_entity
    @entity = Entry.find params[:id]
    raise record_not_found if @entity.deleted?
  end

  def set_adjacent_entities
    privacy   = Entry.privacy_for_user(current_user)
    @adjacent = {
        prev: Entry.with_privacy(privacy).where('id < ?', @entity.id).order('id desc').first,
        next: Entry.with_privacy(privacy).where('id > ?', @entity.id).order('id asc').first
    }
  end
end
