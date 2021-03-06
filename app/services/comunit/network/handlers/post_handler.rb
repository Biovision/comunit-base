# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling posts
      class PostHandler < Comunit::Network::Handler
        def self.since
          10
        end

        def self.permitted_attributes
          super + %i[
            ip updated_at show_owner translation time_required publication_time
            slug title image_alt_text image_name image_source_name
            image_source_link original_title source_name source_link meta_title
            meta_keywords meta_description author_name author_title author_url
            translator_name lead body
          ]
        end

        def meta_for_remote
          meta = super
          meta[:agent] = entity.agent&.name
          if entity.attributes.key?('image') && !entity.image.blank?
            meta[:image_path] = entity.image.path
            meta[:image_url] = host + entity.image.url
          end

          meta
        end

        protected

        def after_pull
          apply_attachments
          apply_post_categories if entity.respond_to?(:post_categories)
          apply_taxa if entity.respond_to?(:taxa)
          forward if self.class.central_site?
          true
        end

        def forward
          site_ids = entity.post_categories.pluck(:site_id).uniq
          log_info "Forward to #{site_ids}"
          Site.where(id: site_ids).each do |other_site|
            next if other_site == entity.site

            NetworkEntitySyncJob.perform_later(entity.class.to_s, entity.id, other_site.uuid)
          end
        end

        def pull_data
          apply_attributes
          apply_post_type
          apply_user
          apply_region
          apply_image
          apply_simple_image
        end

        def relationships_for_remote
          result = {
            user: UserHandler.relationship_data(entity.user),
            attachments: attachments_for_remote
          }

          result[:region] = RegionHandler.relationship_data(entity.region) if entity.attributes.key?('region_id')
          if entity.attributes.key?('post_type_id')
            result[:post_type] = PostTypeHandler.relationship_data(entity.post_type)
          end
          result[:post_categories] = post_categories_for_remote if entity.respond_to?(:post_categories)
          result[:taxa] = taxa_for_remote if entity.respond_to?(:taxa)

          result
        end

        def attachments_for_remote
          collection = entity.post_attachments.map do |item|
            PostAttachmentHandler.relationship_data(item, false)
          end
          collection.any? ? { data: collection } : nil
        end

        def post_categories_for_remote
          collection = entity.post_categories.map do |item|
            PostCategoryHandler.relationship_data(item, false)
          end
          collection.any? ? { data: collection } : nil
        end

        def taxa_for_remote
          collection = entity.taxa.map do |item|
            TaxonHandler.relationship_data(item, false)
          end
          collection.any? ? { data: collection } : nil
        end

        def apply_attachments
          data.dig(:relationships, :attachments, :data)&.each do |data|
            PostAttachmentHandler.pull_for_post(entity, data)
          end
        end

        def apply_post_categories
          data.dig(:relationships, :post_categories, :data)&.each do |data|
            PostCategoryHandler.pull_for_post(entity, data)
          end
        end

        def apply_taxa
          data.dig(:relationships, :taxa, :data)&.each do |data|
            TaxonHandler.pull_for_post(entity, data)
          end
        end
      end
    end
  end
end
