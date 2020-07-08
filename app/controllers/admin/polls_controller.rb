# frozen_string_literal: true

# Administrative part of handling polls
class Admin::PollsController < AdminController
  include ToggleableEntity
  
  before_action :set_entity, except: :index

  # get /admin/polls
  def index
    @collection = Poll.page_for_administration(current_page)
  end

  # get /admin/polls/:id
  def show
  end

  # get /admin/polls/:id/users
  def users
    @collection = @entity.poll_users.list_for_administration
  end

  # post /admin/polls/:id/users
  def add_user
    user = User.find_by(id: params[:user_id])

    @entity.add_user(user) unless user.nil?

    render :users
  end

  # delete /admin/polls/:id/users/:user_id
  def remove_user
    user = User.find_by(id: params[:user_id])

    @entity.remove_user(user) unless user.nil?

    render :users
  end

  private

  def component_class
    Biovision::Components::PollsComponent
  end

  def set_entity
    @entity = Poll.find_by(id: params[:id])
    handle_http_404('Cannot find poll') if @entity.nil?
  end
end
