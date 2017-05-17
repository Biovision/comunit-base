class Admin::ThemesController < AdminController
  before_action :restrict_access
  before_action :set_entity, except: [:index]

  # get /admin/themes
  def index
    @collection = Theme.page_for_administration
  end

  # get /admin/themes/:id
  def show
  end

  private

  def restrict_access
    require_privilege :administrator
  end

  def set_entity
    @entity = Theme.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find theme')
    end
  end
end
