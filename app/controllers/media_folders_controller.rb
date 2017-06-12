class MediaFoldersController < AdminController
  before_action :set_entity, only: [:edit, :update, :destroy]
  before_action :restrict_editing, only: [:edit, :update, :destroy]

  # post /media_folders
  def create
    @entity = MediaFolder.new(creation_parameters)
    if @entity.save
      cache_relatives
      redirect_to admin_media_folder_path(@entity.id)
    else
      render :new, status: :bad_request
    end
  end

  # get /media_folders/:id/edit
  def edit
  end

  # patch /media_folders/:id
  def update
    if @entity.update(entity_parameters)
      cache_relatives
      redirect_to admin_media_folder_path(@entity.id), notice: t('media_folders.update.success')
    else
      render :edit, status: :bad_request
    end
  end

  # delete /media_folders/:id
  def destroy
    if @entity.update deleted: true
      flash[:notice] = t('media_folders.destroy.success')
    end
    redirect_to admin_media_folders_path
  end

  private

  def restrict_access
    require_privilege_group :editors
  end

  def set_entity
    @entity = MediaFolder.find_by(id: params[:id], deleted: false)
    if @entity.nil?
      handle_http_404('Cannot find media folder')
    end
  end

  def restrict_editing
    if @entity.locked?
      redirect_to admin_media_folder_path(@entity.id), alert: t('media_folders.edit.forbidden')
    end
  end

  def entity_parameters
    params.require(:media_folder).permit(MediaFolder.entity_parameters)
  end

  def creation_parameters
    params.require(:media_folder).permit(MediaFolder.creation_parameters)
  end

  def cache_relatives
    @entity.cache_parents!
    unless @entity.parent.blank?
      parent = @entity.parent
      parent.cache_children!
      parent.save
    end
  end
end
