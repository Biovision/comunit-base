# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling sites
      class SiteHandler < Comunit::Network::Handler
        def self.since
          9
        end

        def self.ignored_attributes
          super + %i[token]
        end

        def self.permitted_attributes
          super + %i[active description host name version]
        end
      end
    end
  end
end
