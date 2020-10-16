# frozen_string_literal: true

# Handling taxon types
class TaxonTypesController < AdminController
  include CreateAndModifyEntities

  private

  def component_class
    Biovision::Components::TaxonomyComponent
  end
end
