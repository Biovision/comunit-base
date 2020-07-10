# frozen_string_literal: true

# Administrative part of sites management
class Admin::SitesController < AdminController
  include ToggleableEntity

  before_action :set_entity, except: :index

  # get /admin/sites
  def index
    @collection = Site.page_for_administration(current_page)
  end

  # get /admin/sites/:id
  def show
  end

  # get /admin/sites/:id/users
  def users
    @collection = @entity.site_users.list_for_administration
  end

  # put /admin/sites/:id/users/:user_id
  def add_user
    @entity.add_user(User.find_by(id: params[:user_id]))

    head :no_content
  end

  # delete /admin/sites/:id/users/:user_id
  def remove_user
    @entity.remove_user(User.find_by(id: params[:user_id]))

    head :no_content
  end

  private

  def component_class
    Biovision::Components::ComunitComponent
  end

  def set_entity
    @entity = Site.find_by(id: params[:id])
    handle_http_404('Cannot find site') if @entity.nil?
  end
end
