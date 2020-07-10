# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling decisions
      class DecisionHandler < Comunit::Network::Handler
        def self.permitted_attributes
          super + %i[name body answers]
        end
      end
    end
  end
end
