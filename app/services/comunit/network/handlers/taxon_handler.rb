# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling taxa
      class TaxonHandler < Comunit::Network::Handler
        def self.since
          13
        end

        def self.permitted_attributes
          super + %i[name nav_text slug]
        end

        protected

        def pull_data
          apply_attributes
          apply_parent
          apply_taxon_type
        end

        def relationships_for_remote
          {
            parent: TaxonHandler.relationship_data(entity.parent),
            taxon_type: TaxonTypeHandler.relationship_data(entity.taxon_type),
          }
        end

        def apply_taxon_type
          criteria = { uuid: dig_related_id(:taxon_type) }
          entity.taxon_type = TaxonType.find_by(criteria)
        end

        def apply_parent
          entity.parent = Taxon.find_by(uuid: dig_related_id(:parent))
        end
      end
    end
  end
end
