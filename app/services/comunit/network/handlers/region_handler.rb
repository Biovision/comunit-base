# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling regions
      class RegionHandler < Comunit::Network::Handler
        def self.since
          10
        end

        def self.ignored_attributes
          super + %w[long_slug]
        end

        def self.permitted_attributes
          super + %i[latitude locative longitude name short_name slug visible]
        end

        protected

        def pull_data
          apply_attributes
          apply_parent
          apply_country
        end

        def relationships_for_remote
          {
            parent: RegionHandler.relationship_data(entity.parent),
            country: {
              data: {
                id: entity.country.slug,
                type: entity.country.class.table_name
              }
            }
          }
        end

        def apply_country
          entity.country = Country.find_by(slug: dig_related_id(:country))
        end

        def apply_parent
          parent_id = dig_related_id(:parent)
          entity.parent = parent_id.nil? ? nil : Region.find_by(uuid: parent_id)
        end
      end
    end
  end
end
