# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling posts
      class PostAttachmentHandler < Comunit::Network::Handler
        def self.since
          10
        end

        # @param [PostAttachment] entity
        # @param [TrueClass|FalseClass] wrap
        def self.relationship_data(entity, wrap = true)
          return nil if entity.nil?

          data = {
            id: entity.uuid,
            type: entity.class.table_name,
            attributes: { name: entity.name },
            meta: {
              file_path: entity.file.path, file_url: host + entity.file.url
            }
          }
          wrap ? { data: data } : data
        end

        # @param [Post] post
        # @param [Hash] data
        def self.pull_for_post(post, data)
          entity = PostAttachment.find_or_initialize_by(uuid: data[:id])
          entity.post = post
          entity.name = data.dig(:attributes, :name)
          file_path = data.dig(:meta, :file_path)
          unless file_path.blank?
            if File.exist?(file_path)
              entity.file = Pathname.new(file_path).open
            else
              file_url = data.dig(:meta, :file_url)
              entity.remote_file_url = file_url unless file_url.blank?
            end
          end

          entity.save
        end
      end
    end
  end
end
