# frozen_string_literal: true

# Synchronizing posts with central site
class NetworkManager::PostHandler < NetworkManager

  private

  def prepare_entity_data
    ignored = %w[image agent_id user_id]
    attributes = @entity.attributes.reject { |a| ignored.include?(a) }

    data = {
      entity: attributes,
      owner: @entity.user&.uuid,
      agent: @entity.agent&.name
    }

    data[:image_path] = @entity.image.url unless @entity.image.blank?

    data
  end
end
