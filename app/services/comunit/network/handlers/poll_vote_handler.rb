# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling polls
      class PollVoteHandler < Comunit::Network::Handler
        protected

        def relationships_for_remote
          {
            user: UserHandler.relationship_data(entity.user),
            poll_answer: PollAnswerHandler.relationship_data(entity.poll_answer)
          }
        end

        def pull_data
          assign_attributes
          apply_poll_answer
          apply_user
          fallback_slug = "#{entity.id}:#{entity.agent_id}"
          entity.slug = entity.user.nil? ? fallback_slug : entity.user_id.to_s
        end

        def apply_poll_answer
          clause = { uuid: dig_related_id(:poll_answer) }
          entity.poll_answer = PollAnswer.find_by(clause)
        end
      end
    end
  end
end
