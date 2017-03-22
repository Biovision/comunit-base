class Admin::TeamsController < AdminController
  before_action :set_entity, except: [:index]
  before_action :set_privilege, only: [:add_privilege, :remove_privilege]

  # get /admin/teams
  def index
    @collection = Team.page_for_administration
  end

  # get /admin/teams/:id
  def show
    @collection = Privilege.order('slug asc')
  end

  # put /admin/teams/:id/privileges/:privilege_id
  def add_privilege
    link = @entity.add_privilege(@privilege)

    render json: { data: { link_id: link.id } }
  end

  # delete /admin/teams/:id/privileges/:privilege_id
  def remove_privilege
    @entity.remove_privilege(@privilege)

    head :no_content
  end

  # post /admin/teams/:id/priority
  def priority
    render json: { data: @entity.change_priority(params[:delta].to_s.to_i) }
  end

  protected

  def restrict_access
    require_privilege :teams_manager
  end

  def set_entity
    @entity = Team.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404("Cannot find team #{params[:id]}")
    end
  end

  def set_privilege
    @privilege = Privilege.find_by(id: params[:privilege_id])
    if @entity.nil?
      handle_http_404("Cannot find privilege #{params[:privilege_id]}")
    end
  end
end
