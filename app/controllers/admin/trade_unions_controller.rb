# frozen_string_literal: true

# Administrative trade union handling
class Admin::TradeUnionsController < AdminController
  include ListAndShowEntities
  include CreateAndModifyEntities

  before_action :set_entity, except: %i[check create index new]

  private

  def component_class
    Biovision::Components::TradeUnionsComponent
  end
end
