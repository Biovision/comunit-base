# frozen_string_literal: true

# Parse post body and synchronize post with main site
class NetworkPostSyncJob < ApplicationJob
  queue_as :default

  # @param [Integer] entity_id
  # @param [TrueClass|FalseClass] for_update
  def perform(entity_id, for_update = false)
    entity = Post.find_by(id: entity_id)

    return if entity.nil?

    handler = NetworkManager::PostHandler.new

    entity.update(parsed_body: PostManager.new(entity).parsed_body)

    return unless Rails.env.production?

    for_update ? handler.update_remote(entity) : handler.create_remote(entity)
  end
end
