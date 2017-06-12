class MediaFilesController < AdminController
  before_action :set_entity, except: [:new, :create]

  # get /media_files/new
  def new
    @entity = MediaFile.new
  end

  # post /media_files
  def create
    @entity = MediaFile.new(creation_parameters)
    if @entity.save
      redirect_to(admin_media_file_path(@entity.id))
    else
      render :new, status: :bad_request
    end
  end

  # get /media_files/:id/edit
  def edit
  end

  # patch /media_files/:id
  def update
    if @entity.update(entity_parameters)
      redirect_to admin_media_file_path(@entity.id), notice: t('media_files.update.success')
    else
      render :edit, status: :bad_request
    end
  end

  # delete /media_files/:id
  def destroy
    if @entity.destroy
      flash[:notice] = t('media_files.destroy.success')
    end
    redirect_to admin_media_files
  end

  private

  def restrict_access
    require_privilege_group :editors
  end

  def set_entity
    @entity = MediaFile.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find media file')
    end
  end

  def entity_parameters
    params.require(:media_file).permit(MediaFile.entity_parameters)
  end

  def creation_parameters
    permitted    = MediaFile.creation_parameters
    from_request = params.require(:media_file).permit(permitted)
    from_request.merge(uploading_parameters).merge(owner_for_entity(true))
  end

  def uploading_parameters
    {
      original_name: params.dig(:media_file, :file)&.original_filename,
      mime_type:     params.dig(:media_file, :file)&.content_type
    }
  end
end
