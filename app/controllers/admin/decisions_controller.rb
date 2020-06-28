# frozen_string_literal: true

# Administrative part for decisions
class Admin::DecisionsController < AdminController
  include ToggleableEntity

  before_action :set_entity, except: :index

  # get /admin/decisions
  def index
    @collection = Decision.list_for_administration
  end

  # get /admin/decisions/:id
  def show
  end

  private

  def component_class
    Biovision::Components::DecisionsComponent
  end

  def set_entity
    @entity = Decision.find_by(id: params[:id])
    handle_http_404('Cannot find decision') if @entity.nil?
  end
end
