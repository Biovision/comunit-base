# frozen_string_literal: true

# Managing decisions
class DecisionsController < ApplicationController
  before_action :restrict_access, only: %i[check new create edit update destroy]
  before_action :restrict_anonymous_access, only: :vote
  before_action :set_entity, only: %i[edit update destroy]
  before_action :set_decision, only: %i[show vote]

  layout 'admin', only: %i[check new create edit update destroy]

  # post /decisions/check
  def check
    @entity = Decision.instance_for_check(params[:entity_id], entity_parameters)

    render 'shared/forms/check'
  end

  # get /decisions
  def index
    @collection = Decision.list_for_visitors
  end

  # get /decisions/:id
  def show
  end

  # post /decisions/:id/vote
  def vote
    @entity.add_vote(current_user, param_from_request(:answer))

    form_processed_ok(decision_path(id: @entity.uuid))
  end

  # get /decisions/new
  def new
    @entity = Decision.new
  end

  # post /decisions
  def create
    @entity = Decision.new(entity_parameters)
    if @entity.save
      @entity.add_answers(params.require(:answers).permit!)
      # NetworkEntitySyncJob.perform_later(@entity.class.to_s, @entity.id)
      form_processed_ok(admin_decision_path(id: @entity.id))
    else
      form_processed_with_error(:new)
    end
  end

  # get /decisions/:id/edit
  def edit
  end

  # patch /decisions/:id
  def update
    if @entity.update(entity_parameters)
      @entity.add_answers(params.require(:answers).permit!)
      # NetworkEntitySyncJob.perform_later(@entity.class.to_s, @entity.id)
      form_processed_ok(admin_decision_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /decisions/:id
  def destroy
    flash[:notice] = t('.success') if @entity.destroy

    redirect_to(admin_decisions_path)
  end

  protected

  def component_class
    Biovision::Components::DecisionsComponent
  end

  def restrict_access
    error = "User #{current_user&.id} has no privileges"

    handle_http_401(error) unless component_handler.allow?
  end

  def set_entity
    @entity = Decision.find_by(id: params[:id])
    handle_http_404('Cannot find decision') if @entity.nil?
  end

  def set_decision
    @entity = Decision.list_for_visitors.find_by(uuid: params[:id])
    handle_http_404('Cannot find decision') if @entity.nil?
  end

  def entity_parameters
    params.require(:decision).permit(Decision.entity_parameters)
  end
end
