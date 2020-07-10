# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling deed categories
      class DeedCategoryHandler < Comunit::Network::Handler
        def self.permitted_attributes
          super + %i[name]
        end

        protected

        def relationships_for_remote
          {
            parent: DeedCategoryHandler.relationship_data(entity.parent)
          }
        end

        def pull_data
          assign_attributes
          apply_parent
        end

        def apply_parent
          entity.parent = DeedCategory.find_by(uuid: dig_related_id(:parent))
        end
      end
    end
  end
end
