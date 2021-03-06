# frozen_string_literal: true

# Administrative part for regions management
class Admin::RegionsController < AdminController
  include ToggleableEntity
  include EntityPriority

  before_action :set_entity, except: :index

  # get /admin/regions
  def index
    component = Biovision::Components::RegionsComponent
    country_id = params[:country_id] || component.default_country_id
    allowed_ids = component_handler.allowed_region_ids

    @collection = Region.for_tree(country_id).only_with_ids(allowed_ids)
  end

  # get /admin/regions/:id
  def show
  end

  # put /admin/regions/:id/users/:user_id
  def add_user
    @entity.add_user(User.find_by(id: params[:user_id]))

    head :no_content
  end

  # delete /admin/regions/:id/users/:user_id
  def remove_user
    @entity.remove_user(User.find_by(id: params[:user_id]))

    head :no_content
  end

  private

  def component_class
    Biovision::Components::RegionsComponent
  end

  def set_entity
    @entity = Region.find_by(id: params[:id])
    handle_http_404('Cannot find region') if @entity.nil?
  end
end
