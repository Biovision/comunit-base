class AlbumsController < ApplicationController
  before_action :restrict_access, except: [:show]
  before_action :set_entity, only: [:show, :edit, :update, :destroy]

  layout 'admin', except: [:show]

  # get /albums/new
  def new
    @entity = Album.new
  end

  # get /albums/:id
  def show
    @collection = @entity.photos.page_for_visitors(current_page)
  end

  # post /albums
  def create
    @entity = Album.new(creation_parameters)
    if @entity.save
      redirect_to(admin_album_path(id: @entity.id))
    else
      render :new, status: :bad_request
    end
  end

  # get /albums/:id/edit
  def edit
  end

  # patch /albums/:id
  def update
    if @entity.update(entity_parameters)
      redirect_to admin_album_path(id: @entity.id), notice: t('albums.update.success')
    else
      render :edit, status: :bad_request
    end
  end

  # delete /albums/:id
  def destroy
    if @entity.destroy
      flash[:notice] = t('albums.destroy.success')
    end
    redirect_to admin_albums_path
  end

  private

  def restrict_access
    require_privilege :album_manager
  end

  def set_entity
    @entity = Album.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404("Cannot find album #{params[:id]}")
    end
  end

  def entity_parameters
    params.require(:album).permit(Album.entity_parameters)
  end

  def creation_parameters
    entity_parameters.merge(owner_for_entity)
  end
end
