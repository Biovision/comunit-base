class Admin::PhotosController < AdminController
  before_action :set_entity

  # get /admin/photos/:id
  def show
  end

  # post /admin/photos/:id/priority
  def priority
    render json: { data: @entity.change_priority(params[:delta].to_s.to_i) }
  end

  private

  def set_entity
    @entity = Photo.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find album')
    end
  end
end
