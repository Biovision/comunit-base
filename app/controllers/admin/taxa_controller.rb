# frozen_string_literal: true

# Administrative part of taxon management
class Admin::TaxaController < AdminController
  include EntityPriority
  include ToggleableEntity

  before_action :set_entity

  # get /admin/taxa/:id
  def show
  end

  private

  def component_class
    Biovision::Components::TaxonomyComponent
  end

  def set_entity
    @entity = Taxon.for_current_site.find_by(id: params[:id])
    handle_http_404('Cannot find taxon') if @entity.nil?
  end
end
