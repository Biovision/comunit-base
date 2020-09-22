# frozen_string_literal: true

# Administrative part of taxon management
class Admin::TaxonsController < AdminController
  include EntityPriority
  include ToggleableEntity

  before_action :set_entity

  # get /admin/taxons/:id
  def show
  end

  private

  def component_class
    Biovision::Components::PostsComponent
  end

  def restrict_access
    error = 'Managing taxons is not allowed'
    handle_http_401(error) unless component_handler.allow?('chief_editor')
  end

  def set_entity
    @entity = Taxon.for_current_site.find_by(id: params[:id])
    handle_http_404('Cannot find taxon') if @entity.nil?
  end
end
