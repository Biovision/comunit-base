# frozen_string_literal: true

# Managing post groups
class Admin::PostGroupsController < AdminController
  include CreateAndModifyEntities
  include ListAndShowEntities
  include EntityPriority
  include ToggleableEntity

  before_action :set_entity, except: %i[check create index new]

  # put /admin/post_groups/:id/taxa/:taxon_id
  def add_taxon
    @entity.add_taxon(Taxon.find_by(id: params[:taxon_id]))

    head :no_content
  end

  # delete /admin/post_groups/:id/taxa/:taxon_id
  def remove_taxon
    @entity.remove_taxon(Taxon.find_by(id: params[:taxon_id]))

    head :no_content
  end

  private

  def component_class
    Biovision::Components::PostsComponent
  end

  def restrict_access
    error = 'Managing post groups is not allowed'
    handle_http_401(error) unless component_handler.allow?('chief_editor')
  end
end
