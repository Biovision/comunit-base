# frozen_string_literal: true

# Synchronizing post types with central site
class NetworkManager::PostTypeHandler < NetworkManager
  # @param [PostType] entity
  def self.relationship_data(entity)
    {
      id: entity.uuid,
      type: entity.class.table_name,
      attributes: {
        slug: entity.slug
      }
    }
  end
end
