# frozen_string_literal: true

# Administrative part for decision_users
class Admin::DecisionUsersController < AdminController
  before_action :set_entity, except: :index

  # get /admin/decision_users
  def index
    @collection = DecisionUser.page_for_administration(current_page)
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
