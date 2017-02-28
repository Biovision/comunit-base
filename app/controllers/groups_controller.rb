class GroupsController < ApplicationController
  before_action :restrict_access
  before_action :set_entity, only: [:edit, :update, :destroy]

  # get /groups/new
  def new
    @entity = Group.new
  end

  # post /groups
  def create
    @entity = Group.new(entity_parameters)
    if @entity.save
      redirect_to(admin_group_path(@entity))
    else
      render :new, status: :bad_request
    end
  end

  # get /groups/:id/edit
  def edit
  end

  # patch /groups/:id
  def update
    if @entity.update(entity_parameters)
      redirect_to admin_group_path(@entity), notice: t('groups.update.success')
    else
      render :edit, status: :bad_request
    end
  end

  # delete /groups/:id
  def destroy
    if @entity.destroy
      flash[:notice] = t('groups.destroy.success')
    end
    redirect_to admin_groups_path
  end

  private

  def restrict_access
    require_privilege :group_manager
  end

  def set_entity
    @entity = Group.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404("Cannot find group #{params[:id]}")
    end
  end

  def entity_parameters
    params.require(:group).permit(Group.entity_parameters)
  end
end
