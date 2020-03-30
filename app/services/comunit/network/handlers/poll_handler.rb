# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling polls
      class PollHandler < Comunit::Network::Handler
        def self.permitted_attributes
          %i[
            active allow_comments anonymous_votes created_at description
            end_date exclusive ip name open_results show_on_homepage visible
          ]
        end

        def self.ignored_attributes
          %w[
            agent_id comments_count data id poll_questions_count pollable_id
            pollable_type simple_image_id updated_at user_id
          ]
        end

        def prepare_model_data
          data = {
            id: entity.uuid,
            type: entity.class.table_name,
            attributes: attributes_for_remote,
            relationships: relationships_for_remote,
            meta: {}
          }

          data[:meta][:agent] = entity.agent&.name

          data
        end

        protected

        def pull_data
          apply_attributes
          apply_user
          apply_agent
        end
      end
    end
  end
end
