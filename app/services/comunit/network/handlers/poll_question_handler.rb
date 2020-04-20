# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling poll questions
      class PollQuestionHandler < Comunit::Network::Handler
        def self.permitted_attributes
          %i[comment created_at multiple_choice priority text]
        end

        protected

        def relationships_for_remote
          {
            poll: PollHandler.relationship_data(entity.poll)
          }
        end

        def pull_data
          apply_attributes
          apply_poll
        end

        def apply_poll
          entity.poll = Poll.find_by(uuid: dig_related_id(:poll))
        end
      end
    end
  end
end
