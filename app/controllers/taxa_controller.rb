# frozen_string_literal: true

# Handling taxa
class TaxaController < AdminController
  include CreateAndModifyEntities

  private

  def component_class
    Biovision::Components::TaxonomyComponent
  end
end
