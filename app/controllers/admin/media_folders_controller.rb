class Admin::MediaFoldersController < AdminController
  include LockableEntity

  before_action :restrict_access
  before_action :set_entity, except: [:index]
  before_action :restrict_lock, only: [:lock, :unlock]

  # get /admin/media_folders
  def index
    @collection = MediaFolder.page_for_administration
  end

  # get /admin/media_folders/:id
  def show
  end

  private

  def restrict_access
    require_privilege_group :editors
  end

  def restrict_lock
    require_privilege :chief_editor
  end

  def set_entity
    @entity = MediaFolder.find_by(id: params[:id], deleted: false)
    if @entity.nil?
      handle_http_404('Cannot find media folder')
    end
  end
end
