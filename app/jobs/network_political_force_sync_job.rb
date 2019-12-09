# frozen_string_literal: true

# Synchronize political_force with main site
class NetworkPoliticalForceSyncJob < ApplicationJob
  queue_as :default

  # @param [Integer] entity_id
  # @param [TrueClass|FalseClass] for_update
  def perform(entity_id, for_update = false)
    entity = PoliticalForce.find_by(id: entity_id)

    return if entity.nil?

    handler = NetworkManager::PoliticalForceHandler.new

    return unless Rails.env.production?

    for_update ? handler.update_remote(entity) : handler.create_remote(entity)
  end
end
