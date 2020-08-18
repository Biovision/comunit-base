# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling petition signs
      class PetitionSignHandler < Comunit::Network::Handler
        def self.since
          11
        end

        def self.permitted_attributes
          super + %i[email ip name surname]
        end

        protected

        def pull_data
          apply_attributes
          apply_petition
          apply_user
          apply_agent
        end

        def relationships_for_remote
          {
            user: UserHandler.relationship_data(entity.user),
            petition: PetitionHandler.relationship_data(entity.petition),
          }
        end

        def apply_petition
          entity.petition = Petition.find_by(uuid: dig_related_id(:petition))
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
