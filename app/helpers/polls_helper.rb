# frozen_string_literal: true

# Helper methods for polls component
module PollsHelper
  # @param [Poll] entity
  # @param [String] text
  # @param [Hash] options
  def admin_poll_link(entity, text = entity.name, options = {})
    link_to(text, admin_poll_path(id: entity.id), options)
  end

  # @param [PollQuestion] entity
  # @param [String] text
  # @param [Hash] options
  def admin_poll_question_link(entity, text = entity.text, options = {})
    link_to(text, admin_poll_question_path(id: entity.id), options)
  end

  # @param [PollAnswer] entity
  # @param [String] text
  # @param [Hash] options
  def admin_poll_answer_link(entity, text = entity.text, options = {})
    link_to(text, admin_poll_answer_path(id: entity.id), options)
  end

  # @param [Poll] entity
  # @param [String] text
  # @param [Hash] options
  def poll_link(entity, text = entity.name, options = {})
    link_to(text, poll_path(id: entity.id), options)
  end
end
