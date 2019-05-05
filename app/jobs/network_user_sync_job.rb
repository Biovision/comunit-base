# frozen_string_literal: true

# Synchronize user with main site
class NetworkUserSyncJob < ApplicationJob
  queue_as :default

  # @param [Integer] entity_id
  # @param [TrueClass|FalseClass] for_update
  def perform(entity_id, for_update = false)
    return unless Rails.env.production?

    entity = User.find_by(id: entity_id)

    return if entity.nil?

    handler = NetworkManager::UserHandler.new

    for_update ? handler.update_remote(entity) : handler.create_remote(entity)
  end
end
