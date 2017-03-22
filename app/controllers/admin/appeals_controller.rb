class Admin::AppealsController < AdminController
  before_action :set_entity, except: [:index]

  # get /admin/appeals
  def index
    @collection = Appeal.page_for_administration(current_page)
  end

  # get /admin/appeals/:id
  def show
  end

  # post /admin/appeals/:id/toggle
  def toggle
    render json: { data: @entity.toggle_parameter(params[:parameter].to_s) }
  end

  private

  def restrict_access
    require_privilege :feedback_manager
  end

  def set_entity
    @entity = Appeal.find_by(id: params[:id], deleted: false)
    if @entity.nil?
      handle_http_404('Cannot find appeal')
    end
  end
end
