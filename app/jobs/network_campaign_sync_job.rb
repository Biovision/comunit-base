# frozen_string_literal: true

# Synchronize campaign with main site
class NetworkCampaignSyncJob < ApplicationJob
  queue_as :default

  # @param [Integer] entity_id
  # @param [TrueClass|FalseClass] for_update
  def perform(entity_id, for_update = false)
    entity = Campaign.find_by(id: entity_id)

    return if entity.nil?

    handler = NetworkManager::CampaignHandler.new

    return unless Rails.env.production?

    for_update ? handler.update_remote(entity) : handler.create_remote(entity)
  end
end
