# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling polls
      class PollAnswerHandler < Comunit::Network::Handler
        def self.permitted_attributes
          %i[created_at priority text]
        end

        protected

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
