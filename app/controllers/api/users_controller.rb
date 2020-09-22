class Api::UsersController < ApplicationController
  before_action :restrict_access, except: [:follow, :unfollow]
  before_action :restrict_anonymous_access, only: [:follow, :unfollow]
  before_action :set_entity

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
    head :gone
  end

  # delete /api/users/:id/privileges/:privilege_id
  def revoke_privilege
    head :gone
  end

  private

  def set_entity
    @entity = User.find_by(id: params[:id], deleted: false)
    if @entity.nil?
      handle_http_404("Cannot find non-deleted user with id #{params[:id]}")
    end
  end

  def restrict_access
    handle_http_403('Forbidden') unless current_user&.super_user?
  end

  # @param [UserLink] link
  def notify_followee(link)
    category = Notification.category_from_object(link)
    Notification.notify(link.followee, category, link.follower_id)
  end
end
