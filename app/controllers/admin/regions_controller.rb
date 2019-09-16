# frozen_string_literal: true

# Administrative part of regions handler
class Admin::RegionsController < AdminController
  include ToggleableEntity
  include LockableEntity
  include EntityPriority

  before_action :set_entity, except: [:index]

  # get /admin/regions
  def index
    component = Biovision::Components::RegionsComponent
    country_id = params[:country_id] || component.default_country_id
    @collection = Region.for_tree(country_id)
  end

  # get /admin/regions/:id
  def show
  end

  private

  def set_entity
    @entity = Region.find_by(id: params[:id])
    handle_http_404('Cannot find region') if @entity.nil?
  end
end
