class TeamsController < AdminController
  before_action :set_entity, only: [:edit, :update, :destroy]

  # get /teams/new
  def new
    @entity = Team.new
  end

  # post /teams
  def create
    @entity = Team.new(entity_parameters)
    if @entity.save
      redirect_to(admin_team_path(@entity))
    else
      render :new, status: :bad_request
    end
  end

  # get /teams/:id/edit
  def edit
  end

  # patch /teams/:id
  def update
    if @entity.update(entity_parameters)
      redirect_to admin_team_path(@entity), notice: t('teams.update.success')
    else
      render :edit, status: :bad_request
    end
  end

  # delete /teams/:id
  def destroy
    if @entity.destroy
      flash[:notice] = t('teams.destroy.success')
    end
    redirect_to admin_teams_path
  end

  private

  def restrict_access
    require_privilege :teams_manager
  end

  def set_entity
    @entity = Team.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404("Cannot find team #{params[:id]}")
    end
  end

  def entity_parameters
    params.require(:team).permit(Team.entity_parameters)
  end
end
