# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling trade unions
      class TradeUnionHandler < Comunit::Network::Handler
        def self.since
          15
        end

        def self.permitted_attributes
          super + %i[name lead description]
        end

        protected

        def pull_data
          apply_attributes
          apply_simple_image
        end

        def relationships_for_remote
          {
            simple_image: SimpleImage.relationship_data(entity.simple_image)
          }
        end
      end
    end
  end
end
