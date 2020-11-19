# frozen_string_literal: true

# Administrative part of taxon management
class Admin::TaxaController < AdminController
  include CreateAndModifyEntities
  include ListAndShowEntities
  include EntityPriority
  include ToggleableEntity
  include LinkedUsers

  before_action :set_entity, except: %i[check create index new]

  # get /admin/taxa/:id
  def show
    @user = User.find_by(id: params[:user_id])
  end

  # get /admin/taxa/:id/children
  def children
    @user = User.find_by(id: params[:user_id])
    @collection = @entity.child_items.list_for_administration
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
