# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling petitions
      class PetitionHandler < Comunit::Network::Handler
        def self.since
          11
        end

        def self.permitted_attributes
          super + %i[ip title description]
        end

        protected

        def pull_data
          apply_attributes
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
