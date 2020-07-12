# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling post categories
      class PostCategoryHandler < Comunit::Network::Handler
        def self.since
          9
        end

        def self.permitted_attributes
          super + %i[meta_description name nav_text priority slug]
        end

        protected

        def pull_data
          apply_attributes
          apply_site
          apply_parent
        end

        def relationships_for_remote
          {
            parent: PostCategoryHandler.relationship_data(entity.parent),
            post_type: {
              data: {
                id: entity.post_type.slug,
                type: entity.post_type.class.table_name
              }
            },
            site: SiteHandler.relationship_data(entity.site)
          }
        end

        def apply_post_type
          @entity.post_type = PostType.find_by(slug: dig_related_id(:post_type))
        end

        def apply_parent
          @entity.parent = PostCategory.find_by(uuid: dig_related_id(:parent))
        end
      end
    end
  end
end
