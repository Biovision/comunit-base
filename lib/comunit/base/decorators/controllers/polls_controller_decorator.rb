# frozen_string_literal: true

PollsController.class_eval do
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

  # post /polls/:id/results
  def answer
    @entity.process_answers(current_user, params.require(:answer), owner_for_entity(true), visitor_slug)
    PollVote.where(poll_answer_id: @entity.answer_ids).each do |vote|
      NetworkEntitySyncJob.perform_later(vote.class.to_s, vote.id)
    end

    redirect_to results_poll_path(id: @entity.id)
  end
end
