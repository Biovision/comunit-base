# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling polls
      class PollAnswerHandler < Comunit::Network::Handler
        protected

        def relationships_for_remote
          {
            poll_question: PollQuestionHandler.relationship_data(entity.poll_question)
          }
        end

        def pull_data
          apply_attributes
          apply_poll_question
        end

        def apply_poll_question
          clause = { uuid: dig_related_id(:poll_question) }
          entity.poll_question = PollQuestion.find_by(clause)
        end
      end
    end
  end
end
