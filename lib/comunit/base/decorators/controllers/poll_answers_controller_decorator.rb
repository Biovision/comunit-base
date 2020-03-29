# frozen_string_literal: true

PollAnswersController.class_eval do
  # post /poll_questions
  def create
    @entity = PollAnswer.new(creation_parameters)
    if @entity.save
      NetworkEntitySyncJob.perform_later(@entity.class.to_s, @entity.id)
      form_processed_ok(admin_poll_answer_path(id: @entity.id))
    else
      form_processed_with_error(:new)
    end
  end
end
