class Admin::AlbumsController < AdminController
  before_action :set_entity, except: [:index]

  # get /admin/albums
  def index
    @collection = Album.page_for_administration(current_page)
  end

  # get /admin/albums/:id
  def show
  end

  # get /admin/albums/:id/photos
  def photos
    @collection = @entity.photos.page_for_administration(current_page)
  end

  # post /admin/albums/:id/toggle
  def toggle
    render json: { data: @entity.toggle_parameter(params[:parameter].to_s) }
  end

  private

  def restrict_access
    require_privilege :albums_manager
  end

  def set_entity
    @entity = Album.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find album')
    end
  end
end
