# frozen_string_literal: true

# Administrative part for decision_users
class Admin::DecisionUsersController < AdminController
  include ListAndShowEntities
  before_action :set_entity, except: :index

  private

  def component_class
    Biovision::Components::DecisionsComponent
  end
end
