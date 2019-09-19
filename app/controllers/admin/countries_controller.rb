# frozen_string_literal: true

# Administrative part of regions handler
class Admin::CountriesController < AdminController
  before_action :set_entity, except: [:index]

  # get /admin/countries
  def index
    @collection = Country.list_for_administration
  end

  # get /admin/countries/:id
  def show
  end

  private

  def component_slug
    Biovision::Components::RegionsComponent::SLUG
  end

  def set_entity
    @entity = Country.find_by(id: params[:id])
    handle_http_404('Cannot find country') if @entity.nil?
  end
end
