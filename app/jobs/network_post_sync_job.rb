# frozen_string_literal: true

# Synchronize post with main site
class NetworkPostSyncJob < ApplicationJob
  queue_as :default

  # @param [Integer] entity_id
  # @param [TrueClass|FalseClass] for_update
  def perform(entity_id, for_update = false)
    return unless Rails.env.production?

    entity = Post.find_by(id: entity_id)

    return if entity.nil?

    handler = NetworkManager::PostHandler.new

    for_update ? handler.update_remote(entity) : handler.create_remote(entity)
  end
end
