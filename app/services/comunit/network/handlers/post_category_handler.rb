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

        # @param [Post] post
        # @param [Hash] data
        def self.pull_for_post(post, data)
          PostCategory.find_by(uuid: data[:id])&.add_post(post)
        end

        protected

        def pull_data
          apply_attributes
          apply_site
          apply_parent
          apply_post_type
        end

        def relationships_for_remote
          {
            parent: PostCategoryHandler.relationship_data(entity.parent),
            post_type: PostTypeHandler.relationship_data(entity.post_type),
            site: SiteHandler.relationship_data(entity.site)
          }
        end

        def apply_parent
          entity.parent = PostCategory.find_by(uuid: dig_related_id(:parent))
        end
      end
    end
  end
end
