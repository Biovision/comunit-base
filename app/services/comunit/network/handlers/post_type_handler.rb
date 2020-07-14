# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling posts
      class PostTypeHandler < Comunit::Network::Handler
        def self.since
          10
        end

        # @param [PostType] entity
        # @param [TrueClass|FalseClass] wrap
        def self.relationship_data(entity, wrap = true)
          return nil if entity.nil?

          data = { id: entity.slug, type: entity.class.table_name }
          wrap ? { data: data } : data
        end
      end
    end
  end
end
