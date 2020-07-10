# frozen_string_literal: true

# Administrative part for countries management
class Admin::CountriesController < AdminController
  include ToggleableEntity
  include EntityPriority

  before_action :set_entity, except: :index

  # get /admin/countries
  def index
    @collection = Country.list_for_administration
  end

  # get /admin/countries/:id
  def show
  end

  # get /admin/countries/:id/regions
  def regions
    @collection = Region.in_country(@entity).for_tree.list_for_administration
  end

  private

  def component_class
    Biovision::Components::RegionsComponent
  end

  def set_entity
    @entity = Country.find_by(id: params[:id])
    handle_http_404('Cannot find country') if @entity.nil?
  end
end
