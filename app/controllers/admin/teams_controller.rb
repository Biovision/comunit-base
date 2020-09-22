class Admin::TeamsController < AdminController
  before_action :set_entity, except: [:index]

  # get /admin/teams
  def index
    @collection = Team.page_for_administration
  end

  # get /admin/teams/:id
  def show
    @collection = []
  end

  # put /admin/teams/:id/privileges/:privilege_id
  def add_privilege
    head :gone
  end

  # delete /admin/teams/:id/privileges/:privilege_id
  def remove_privilege
    head :gone
  end

  # post /admin/teams/:id/priority
  def priority
    render json: { data: @entity.change_priority(params[:delta].to_s.to_i) }
  end

  protected

  def set_entity
    @entity = Team.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404("Cannot find team #{params[:id]}")
    end
  end
end
