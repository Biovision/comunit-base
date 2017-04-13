class Admin::GroupsController < AdminController
  before_action :set_entity, except: [:index]
  before_action :set_user, only: [:add_user, :remove_user]

  # get /admin/groups
  def index
    @collection = Group.page_for_administration
  end

  # get /admin/groups/:id
  def show
    @collection = @entity.users.page_for_administration(current_page)
  end

  # get /admin/groups/:id/users
  def users
    @filter     = params[:filter] || Hash.new
    @collection = User.page_for_visitors(current_page, @filter)
  end

  # put /admin/groups/:id/users/:user_id
  def add_user
    link = @entity.add_user(@user)

    render json: { data: { link_id: link.id } }
  end

  # delete /admin/groups/:id/users/:user_id
  def remove_user
    @entity.remove_user(@user)

    head :no_content
  end

  protected

  def restrict_access
    require_privilege :group_manager
  end

  def set_entity
    @entity = Group.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404("Cannot find group #{params[:id]}")
    end
  end

  def set_user
    @user = User.find_by(id: params[:user_id])
    if @entity.nil?
      handle_http_404("Cannot find user #{params[:user_id]}")
    end
  end
end
