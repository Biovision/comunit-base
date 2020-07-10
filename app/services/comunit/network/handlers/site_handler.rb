# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling sites
      class SiteHandler < Comunit::Network::Handler
        def self.ignored_attributes
          super + %w[token]
        end

        def self.permitted_attributes
          super + %w[active description host name version]
        end
      end
    end
  end
end
