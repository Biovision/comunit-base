# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling polls
      class PollHandler < Comunit::Network::Handler
        def self.permitted_attributes
          super + %i[
            active allow_comments anonymous_votes description end_date exclusive
            ip name open_results show_on_homepage visible
          ]
        end

        def self.ignored_attributes
          super + %w[pollable_type]
        end

        protected

        def pull_data
          assign_attributes
          apply_user
          apply_agent
        end

        def relationships_for_remote
          {
            user: UserHandler.relationship_data(entity.user)
          }
        end

        def meta_for_remote
          meta = super
          meta[:agent] = entity.agent&.name

          meta
        end
      end
    end
  end
end
