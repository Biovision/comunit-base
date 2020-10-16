# frozen_string_literal: true

# Administrative part of taxon management
class Admin::TaxonTypesController < AdminController
  include ListAndShowEntities

  private

  def component_class
    Biovision::Components::TaxonomyComponent
  end
end
