class UsersController < ApplicationController
  before_action :restrict_access, except: [:index]
  before_action :set_entity, only: [:edit, :update, :destroy]

  # get /users
  def index
    @filter     = params[:filter] || Hash.new
    @collection = User.page_for_visitors(current_page, @filter)
  end

  # get /users/new
  def new
    @entity = User.new
  end

  # post /users
  def create
    @entity = User.new creation_parameters
    if @entity.save
      set_roles
      NetworkManager.new.relink_user(@entity)
      redirect_to admin_user_path(@entity), notice: t('users.create.success')
    else
      render :new, status: :bad_request
    end
  end

  # get /users/:id/edit
  def edit
  end

  # patch /users/:id
  def update
    if @entity.update entity_parameters
      set_roles
      redirect_to admin_user_path(@entity), notice: t('users.update.success')
    else
      render :edit, status: :bad_request
    end
  end

  # delete /users/:id
  def destroy
    if @entity.update(deleted: true)
      flash[:notice] = t('users.destroy.success')
    end
    redirect_to admin_users_path
  end

  protected

  def restrict_access
    require_role :administrator
  end

  def set_entity
    @entity = User.find params[:id]
  end

  def entity_parameters
    params.require(:user).permit(User.entity_parameters)
  end

  def creation_parameters
    params.require(:user).permit(User.creation_parameters).merge(tracking_for_entity)
  end

  def set_roles
    @entity.roles = (params[:roles] || Hash.new)
  end
end
