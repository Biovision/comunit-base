# frozen_string_literal: true

# Administrative part of taxon management
class Admin::TaxonTypesController < AdminController
  include ListAndShowEntities
  include LinkedUsers

  before_action :set_entity, except: :index

  private

  def component_class
    Biovision::Components::TaxonomyComponent
  end
end
