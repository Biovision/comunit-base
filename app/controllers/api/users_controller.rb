class Api::UsersController < ApplicationController
  before_action :restrict_access, except: [:follow, :unfollow]
  before_action :restrict_anonymous_access, only: [:follow, :unfollow]
  before_action :set_entity
  before_action :set_privilege, only: [:grant_privilege, :revoke_privilege]

  # post /api/users/:id/toggle
  def toggle
    render json: { data: @entity.toggle_parameter(params[:parameter].to_s) }
  end

  # put /api/users/:id/follow
  def follow
    link = UserLink.follow(current_user, @entity)
    notify_followee(link)
    render json: { data: { id: link.id } }
  end

  # delete /api/users/:id/follow
  def unfollow
    UserLink.unfollow(current_user, @entity)
    head :no_content
  end

  # put /api/users/:id/privileges/:privilege_id
  def grant_privilege
    @privilege.grant(@entity, @region)

    render json: { data: { user_privilege_ids: @entity.user_privilege_ids } }
  end

  # delete /api/users/:id/privileges/:privilege_id
  def revoke_privilege
    @privilege.revoke(@entity, @region)

    render json: { data: { user_privilege_ids: @entity.user_privilege_ids } }
  end

  private

  def set_entity
    @entity = User.find_by(id: params[:id], deleted: false)
    if @entity.nil?
      handle_http_404("Cannot find non-deleted user with id #{params[:id]}")
    end
  end

  def set_privilege
    @privilege = Privilege.find_by(id: params[:privilege_id], deleted: false)
    if @privilege.nil?
      handle_http_404("Cannot use privilege #{params[:privilege_id]}")
    elsif @privilege.regional?
      @region = Region.find_by(id: params[:region_id], visible: true)
      if @region.nil?
        handle_http_404("Cannot use region #{params[:region_id]}")
      end
    else
      @region = nil
    end
  end

  def restrict_access
    require_privilege :administrator
  end

  # @param [UserLink] link
  def notify_followee(link)
    category = Notification.category_from_object(link)
    Notification.notify(link.followee, category, link.follower_id)
  end
end
