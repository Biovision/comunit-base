# frozen_string_literal: true

# Displaying and editing polls
class PollsController < ApplicationController
  before_action :restrict_access, except: %i[index show results answer]
  before_action :set_entity, except: %i[check index new create]

  layout 'admin', except: %i[check index show results]

  # post /polls/check
  def check
    @entity = Poll.instance_for_check(params[:entity_id], entity_parameters)

    render 'shared/forms/check'
  end

  # get /polls
  def index
    @collection = Poll.page_for_visitors(current_page)
  end

  # get /polls/new
  def new
    @entity = Poll.new
  end

  # post /polls
  def create
    @entity = Poll.new(creation_parameters)
    if @entity.save
      NetworkEntitySyncJob.perform_later(@entity.class.to_s, @entity.id)
      form_processed_ok(admin_poll_path(id: @entity.id))
    else
      form_processed_with_error(:new)
    end
  end

  # get /polls/:id
  def show
    redirect_to polls_path unless @entity.visible_to?(current_user)
  end

  # get /polls/:id/edit
  def edit
  end

  # patch /polls/:id
  def update
    if @entity.update(entity_parameters)
      form_processed_ok(admin_poll_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /polls/:id
  def destroy
    flash[:notice] = t('.success') if @entity.destroy
    redirect_to(admin_polls_path)
  end

  # post /polls/:id/results
  def answer
    @entity.process_answers(current_user, params.require(:answer), owner_for_entity(true), visitor_slug)
    PollVote.where(poll_answer_id: @entity.answer_ids).each do |vote|
      NetworkEntitySyncJob.perform_later(vote.class.to_s, vote.id)
    end

    redirect_to results_poll_path(id: @entity.id)
  end

  # get /polls/:id/results
  def results
    redirect_to poll_path(id: @entity.id) unless @entity.show_results?(current_user)
  end

  protected

  def component_class
    Biovision::Components::PollsComponent
  end

  def restrict_access
    error = 'Managing polls is not allowed for current user'
    handle_http_401(error) unless component_handler.allow?
  end

  def set_entity
    @entity = Poll.find_by(id: params[:id])
    handle_http_404('Cannot find poll') if @entity.nil?
  end

  def entity_parameters
    params.require(:poll).permit(Poll.entity_parameters)
  end

  def creation_parameters
    entity_parameters.merge(owner_for_entity(true))
  end
end
