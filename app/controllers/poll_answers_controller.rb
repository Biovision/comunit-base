# frozen_string_literal: true

# Editing poll answers
class PollAnswersController < AdminController
  before_action :set_entity, only: %i[edit update destroy]

  # post /poll_answers/check
  def check
    @entity = PollAnswer.instance_for_check(params[:entity_id], entity_parameters)

    render 'shared/forms/check'
  end

  # post /poll_answers
  def create
    @entity = PollAnswer.new(creation_parameters)
    if @entity.save
      NetworkEntitySyncJob.perform_later(@entity.class.to_s, @entity.id)
      form_processed_ok(admin_poll_answer_path(id: @entity.id))
    else
      form_processed_with_error(:new)
    end
  end

  # get /poll_answers/:id/edit
  def edit
  end

  # patch /poll_answers/:id
  def update
    if @entity.update(entity_parameters)
      form_processed_ok(admin_poll_question_path(id: @entity.poll_question_id))
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /poll_answers/:id
  def destroy
    flash[:notice] = t('.success') if @entity.destroy
    redirect_to(admin_poll_question_path(id: @entity.poll_question_id))
  end

  protected

  def component_class
    Biovision::Components::PollsComponent
  end

  def set_entity
    @entity = PollAnswer.find_by(id: params[:id])
    handle_http_404('Cannot find poll answer') if @entity.nil?
  end

  def entity_parameters
    params.require(:poll_answer).permit(PollAnswer.entity_parameters)
  end

  def creation_parameters
    params.require(:poll_answer).permit(PollAnswer.creation_parameters)
  end
end
