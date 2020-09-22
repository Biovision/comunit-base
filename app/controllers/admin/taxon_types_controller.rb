# frozen_string_literal: true

# Administrative part of taxon management
class Admin::TaxonTypesController < AdminController
  before_action :set_entity, except: :index

  # get /admin/taxons
  def index
    @collection = TaxonType.for_current_site.list_for_administration
  end

  # get /admin/taxons/:id
  def show
  end

  private

  def component_class
    Biovision::Components::PostsComponent
  end

  def restrict_access
    error = 'Managing taxon types is not allowed'
    handle_http_401(error) unless component_handler.allow?('chief_editor')
  end

  def set_entity
    @entity = TaxonType.for_current_site.find_by(id: params[:id])
    handle_http_404('Cannot find taxon') if @entity.nil?
  end
end
