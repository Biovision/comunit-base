# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling simple images
      class SimpleImageHandler < Comunit::Network::Handler
        def self.since
          13
        end

        def self.permitted_attributes
          super + %i[caption image image_alt_text source_link source_name]
        end

        def self.ignored_attributes
          %w[data id updated_at]
        end

        protected

        def pull_data
          apply_attributes
          apply_component
          apply_image if site.remote?
        end

        def relationships_for_remote
          {
            biovision_component: {
              data: {
                id: entity.biovision_component.slug,
                type: BiovisionComponent.table_name
              }
            }
          }
        end

        def apply_component
          slug = dig_related_id(:biovision_component)
          entity.biovision_component = BiovisionComponent[slug]
        end

        def meta_for_remote
          meta = super
          unless entity.image.blank?
            meta[:image_path] = entity.image.path
            meta[:image_url] = host + entity.image.url
          end

          meta
        end
      end
    end
  end
end
