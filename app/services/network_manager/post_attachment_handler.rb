# frozen_string_literal: true

# Synchronizing post attachments with central site
class NetworkManager::PostAttachmentHandler < NetworkManager
  # @param [PostAttachment] entity
  def self.relationship_data(entity)
    {
      id: entity.id,
      type: entity.class.table_name,
      attributes: {
        name: entity.name
      },
      meta: {
        file_path: entity.file.path
      }
    }
  end
end
