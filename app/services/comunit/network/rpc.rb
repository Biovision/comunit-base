# frozen_string_literal: true

module Comunit
  module Network
    # Shared RPCs
    module Rpc
      # Update simple image
      def rpc_update_simple_image
        simple_image = SimpleImage.find_by(uuid: data[:id])
        return if simple_image.nil?

        entity.update(simple_image: simple_image)
      end
    end
  end
end
