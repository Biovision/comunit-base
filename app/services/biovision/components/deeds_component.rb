# frozen_string_literal: true

module Biovision
  module Components
    # Deed handler
    class DeedsComponent < BaseComponent
      # @param [Deed] deed
      def editable?(deed)
        return false if deed.nil? || user.nil?

        deed.owned_by?(user) || allow?
      end
    end
  end
end
