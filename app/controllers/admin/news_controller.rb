class Admin::NewsController < AdminController
  include ToggleableEntity
  include LockableEntity

  before_action :set_entity, except: [:index, :regions]
  before_action :restrict_locking, only: [:lock, :unlock]
  before_action :restrict_editing, only: [:toggle]

  # get /admin/news
  def index
    @collection = News.page_for_administration(current_page)
  end

  # get /admin/news/:id
  def show
  end

  # get /admin/news/regions
  def regions
    @collection = RegionManager.new(current_user).for_tree(params[:parent_id])
  end

  protected

  def restrict_access
    require_privilege_group :reporters
  end

  def restrict_locking
    require_privilege :chief_editor
  end

  def restrict_editing
    unless @entity.editable_by?(current_user)
      handle_http_403('Entity is not editable')
    end
  end

  def set_entity
    @entity = News.find_by(id: params[:id], deleted: false)
    if @entity.nil?
      handle_http_404('Cannot find news')
    end
  end
end
