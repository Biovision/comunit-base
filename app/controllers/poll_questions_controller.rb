# frozen_string_literal: true

# Managing poll questions
class PollQuestionsController < AdminController
  before_action :set_entity, only: %i[edit update destroy]

  # post /poll_questions/check
  def check
    @entity = PollQuestion.instance_for_check(params[:entity_id], entity_parameters)

    render 'shared/forms/check'
  end

  # post /poll_questions
  def create
    @entity = PollQuestion.new(creation_parameters)
    if @entity.save
      NetworkEntitySyncJob.perform_later(@entity.class.to_s, @entity.id)
      form_processed_ok(admin_poll_question_path(id: @entity.id))
    else
      form_processed_with_error(:new)
    end
  end

  # get /poll_questions/:id/edit
  def edit
  end

  # patch /poll_questions/:id
  def update
    if @entity.update(entity_parameters)
      form_processed_ok(admin_poll_question_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /poll_questions/:id
  def destroy
    flash[:notice] = t('.success') if @entity.destroy
    redirect_to(admin_poll_path(id: @entity.poll_id))
  end

  protected

  def component_class
    Biovision::Components::PollsComponent
  end

  def set_entity
    @entity = PollQuestion.find_by(id: params[:id])
    handle_http_404('Cannot find poll question') if @entity.nil?
  end

  def entity_parameters
    params.require(:poll_question).permit(PollQuestion.entity_parameters)
  end

  def creation_parameters
    params.require(:poll_question).permit(PollQuestion.creation_parameters)
  end
end
