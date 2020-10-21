# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling deeds
      class DeedHandler < Comunit::Network::Handler
        def self.permitted_attributes
          super + %i[description done name offer title]
        end

        protected

        def relationships_for_remote
          {
            user: UserHandler.relationship_data(entity.user),
            # region: Comunit::Network::Handler.relationship_data(entity.region),
            deed_categories: { data: deed_categories_for_remote }
          }
        end

        def meta_for_remote
          meta = { agent: entity.agent&.name }

          unless entity.image.blank?
            meta[:image_path] = entity.image.path
            meta[:image_url] = host + entity.image.url
          end

          meta
        end

        def deed_categories_for_remote
          entity.deed_categories.map do |deed_category|
            DeedCategoryHandler.relationship_data(deed_category, false)
          end
        end

        def pull_data
          apply_attributes
          apply_user
          apply_agent
          # apply_region
          apply_image
        end

        def after_pull
          list = Array(data.dig(:relationships, :deed_categories, :data))
          uuids = list.map(&:id)
          entity.deed_category_ids = DeedCategory.where(uuid: uuids).pluck(:id)

          super
        end
      end
    end
  end
end
