# frozen_string_literal: true

module Comunit
  module Network
    # Applying parts to pulled entities
    module ApplyingParts
      def apply_user
        entity.user = User.find_by(uuid: dig_related_id(:user))
      end

      def apply_site
        entity.site = Site.find_by(uuid: dig_related_id(:site))
      end

      def apply_agent
        entity.agent = Agent[data.dig(:meta, :agent)]
      end

      def apply_simple_image
        image_id = dig_related_id(:simple_image)
        entity.simple_image = SimpleImage.find_by(uuid: image_id)
      end

      def apply_image
        image_path = data.dig(:meta, :image_path)

        return if image_path.blank? || !File.exist?(image_path)

        entity.image = Pathname.new(image_path).open
      end

      def apply_region
        entity.region = Region.find_by(uuid: dig_related_id(:region))
      end

      def apply_post_type
        entity.post_type = PostType.find_by(slug: dig_related_id(:post_type))
      end

      def apply_comunit
        key = Handler::ROOT_KEY
        entity.data[key] = data.dig(:data, key.to_sym)
      end

      # @param [Symbol] key
      def dig_related_id(key)
        data.dig(:relationships, key, :data, :id)
      end
    end
  end
end
