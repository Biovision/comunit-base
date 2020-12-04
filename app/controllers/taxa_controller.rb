# frozen_string_literal: true

# Handling taxa
class TaxaController < AdminController
  include CreateAndModifyEntities

  before_action :set_entity, except: %i[check create new]

  private

  def component_class
    Biovision::Components::TaxonomyComponent
  end
end
