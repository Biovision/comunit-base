# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling sites
      class SiteHandler < Comunit::Network::Handler
        def self.permitted_attributes
          super + %i[active deleted description host name]
        end

        protected

        def pull_data
          apply_attributes
          apply_image
        end
      end
    end
  end
end
