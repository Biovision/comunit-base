# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling deed images
      class DeedImageHandler < Comunit::Network::Handler
        def self.permitted_attributes
          super + %i[caption description priority]
        end

        protected

        def relationships_for_remote
          {
            deed: DeedHandler.relationship_data(entity.deed)
          }
        end

        def meta_for_remote
          meta = {}

          unless entity.image.blank?
            meta[:image_path] = entity.image.path
            meta[:image_url] = host + entity.image.url
          end

          meta
        end

        def pull_data
          apply_attributes
          apply_deed
          apply_image
        end

        def apply_deed
          entity.deed = Deed.find_by(uuid: dig_related_id(:deed))
        end
      end
    end
  end
end
