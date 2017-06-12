class Admin::MediaFilesController < AdminController
  include LockableEntity

  before_action :restrict_access
  before_action :set_entity, except: [:index]
  before_action :restrict_lock, only: [:lock, :unlock]

  # get /admin/media_files
  def index
    @collection = MediaFile.page_for_administration(current_page)
  end

  # get /admin/media_files/:id
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
    @entity = MediaFile.find_by(id: params[:id], deleted: false)
    if @entity.nil?
      handle_http_404('Cannot find media file')
    end
  end
end
