# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling taxon types
      class TaxonTypeHandler < Comunit::Network::Handler
        def self.since
          13
        end

        def self.permitted_attributes
          super + %i[name slug]
        end

        def self.ignored_attributes
          super + %w[priority visible]
        end
      end
    end
  end
end
