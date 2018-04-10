class PhotosController < ApplicationController
  before_action :restrict_access, except: [:show]
  before_action :set_entity, only: [:show, :edit, :update, :destroy]

  layout 'admin', except: [:show]

  # get /photos/new
  def new
    @entity = Photo.new
  end

  # get /photos/:id
  def show
  end

  # post /photos
  def create
    @entity = Photo.new(creation_parameters)
    if @entity.save
      redirect_to(admin_photo_path(id: @entity.id))
    else
      render :new, status: :bad_request
    end
  end

  # get /photos/:id/edit
  def edit
  end

  # patch /photos/:id
  def update
    if @entity.update(entity_parameters)
      redirect_to admin_photo_path(id: @entity.id), notice: t('photos.update.success')
    else
      render :edit, status: :bad_request
    end
  end

  # delete /photos/:id
  def destroy
    if @entity.destroy
      flash[:notice] = t('photos.destroy.success')
    end
    redirect_to admin_photos_path
  end

  private

  def restrict_access
    require_privilege :photo_manager
  end

  def set_entity
    @entity = Photo.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404("Cannot find photo #{params[:id]}")
    end
  end

  def entity_parameters
    params.require(:photo).permit(Photo.entity_parameters)
  end

  def creation_parameters
    params.require(:photo).permit(Photo.creation_parameters)
  end
end
