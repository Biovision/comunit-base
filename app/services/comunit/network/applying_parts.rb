# frozen_string_literal: true

module Comunit
  module Network
    # Applying parts to pulled entities
    module ApplyingParts
      def apply_user
        @entity.user = User.find_by(uuid: dig_related_id(:user))
      end

      def apply_agent
        @entity.agent = Agent[data.dig(:meta, :agent)]
      end

      def apply_image
        image_path = data.dig(:meta, :image_path)

        return if image_path.blank? || !File.exist?(image_path)

        @entity.image = Pathname.new(image_path).open
      end

      def apply_comunit
        key = Handler::ROOT_KEY
        @entity.data[key] = data.dig(:data, key.to_sym)
      end

      # @param [Symbol] key
      def dig_related_id(key)
        data.dig(:relationships, key, :data, :id)
      end
    end
  end
end
