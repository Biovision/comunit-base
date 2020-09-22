class Editorial::UsersController < AdminController
  include ToggleableEntity

  before_action :set_entity, except: [:index]

  # get /editorial/users
  def index
    site_id     = ENV['SITE_ID'].to_i
    @search     = param_from_request(:q)
    @collection = User.where(site_id: site_id).page_for_administration current_page, @search
  end

  # get /editorial/users/:id
  def show
  end

  protected

  def set_entity
    @entity = User.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find user')
    end
  end
end
