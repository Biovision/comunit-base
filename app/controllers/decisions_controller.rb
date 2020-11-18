# frozen_string_literal: true

# Managing decisions
class DecisionsController < ApplicationController
  before_action :restrict_anonymous_access, only: :vote
  before_action :set_decision, only: %i[show vote]

  # get /decisions
  def index
    @collection = Decision.list_for_visitors
  end

  # post /decisions/:id/vote
  def vote
    @entity.add_vote(current_user, param_from_request(:answer))

    form_processed_ok(decision_path(id: @entity.uuid))
  end

  protected

  def component_class
    Biovision::Components::DecisionsComponent
  end

  def set_entity
    @entity = Decision.find_by(id: params[:id])
    handle_http_404('Cannot find decision') if @entity.nil?
  end

  def set_decision
    @entity = Decision.list_for_visitors.find_by(uuid: params[:id])
    handle_http_404('Cannot find decision') if @entity.nil?
  end
end
