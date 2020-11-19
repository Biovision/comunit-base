# frozen_string_literal: true

# Administrative part of taxon management
class Admin::TaxonTypesController < AdminController
  include CreateAndModifyEntities
  include ListAndShowEntities
  include LinkedUsers

  before_action :set_entity, except: %i[check create index new]

  private

  def component_class
    Biovision::Components::TaxonomyComponent
  end
end
