class UsersController < ApplicationController
  before_action :restrict_access, except: %i[check index]
  before_action :set_entity, only: [:edit, :update, :destroy]

  layout 'admin', except: %i[check index]

  # get /users
  def index
    @filter     = params[:filter] || Hash.new
    @collection = User.page_for_visitors(current_page, @filter)
  end

  # post /users/check
  def check
    @entity = User.new(creation_parameters)
  end

  # get /users/new
  def new
    @entity = User.new(consent: true)
  end

  # post /users
  def create
    @entity = User.new(creation_parameters)
    if @entity.save
      NetworkManager::UserHandler.new.relink_user(@entity) if Rails.env.production?

      form_processed_ok(admin_user_path(id: @entity.id))
    else
      form_processed_with_error(:new)
    end
  end

  # get /users/:id/edit
  def edit
  end

  # patch /users/:id
  def update
    if @entity.update(entity_parameters)
      NetworkManager::UserHandler.new.sync_user(@entity) if Rails.env.production?

      form_processed_ok(admin_user_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
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
    require_privilege :administrator
  end

  def set_entity
    @entity = User.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find user')
    end
  end

  def entity_parameters
    parameters = params.require(:user).permit(User.entity_parameters)
    parameters.merge(data: @entity.data.merge(profile: profile_parameters))
  end

  def creation_parameters
    entity_parameters.merge(tracking_for_entity).merge(consent: true)
  end

  def profile_parameters
    if params.key?(:user_profile)
      permitted = UserProfileHandler.allowed_parameters
      dirty     = params.require(:user_profile).permit(permitted)
      UserProfileHandler.clean_parameters(dirty)
    else
      {}
    end
  end
end
