# frozen_string_literal: true

PollQuestionsController.class_eval do
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
end
