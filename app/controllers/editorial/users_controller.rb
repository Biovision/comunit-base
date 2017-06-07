class Editorial::UsersController < AdminController
  include ToggleableEntity

  before_action :set_entity, except: [:index]
  before_action :restrict_toggle, only: [:toggle]

  # get /editorial/users
  def index
    site_id     = ENV['SITE_ID'].to_i
    @filter     = params[:filter] || Hash.new
    @collection = User.where(site_id: site_id).page_for_administration current_page, @filter
  end

  # get /editorial/users/:id
  def show
  end

  protected

  def restrict_access
    require_privilege_group(:editors)
  end

  def restrict_toggle
    require_privilege(:chief_editor)
  end

  def set_entity
    @entity = User.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find user')
    end
  end
end
