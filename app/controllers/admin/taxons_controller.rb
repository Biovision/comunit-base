# frozen_string_literal: true

# Administrative part of taxon management
class Admin::TaxonsController < AdminController
  include EntityPriority
  include ToggleableEntity

  before_action :set_entity, except: :index

  # get /admin/taxons
  def index
    @collection = Taxon.list_for_administration
  end

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
    @entity = Taxon.find_by(id: params[:id])
    handle_http_404('Cannot find taxon') if @entity.nil?
  end
end
