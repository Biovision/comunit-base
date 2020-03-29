# frozen_string_literal: true

# Synchronize entity with main site
class NetworkEntitySyncJob < ApplicationJob
  queue_as :default

  # @param [String] entity_class
  # @param [Integer] entity_id
  def perform(entity_class, entity_id)
    handler = handler_from_string(entity_class)

    return if handler.nil?

    handler.entity = model_from_string(entity_class, entity_id)
    handler.push
  end

  private

  # @param [String] entity_class
  def handler_from_string(entity_class)
    handler_name = "Comunit::Network::Handlers::#{entity_class}Handler"
    handler_name.safe_constantize&.new(nil)
  end

  # @param [String] entity_class
  # @param [Integer] entity_id
  def model_from_string(entity_class, entity_id)
    entity_class.safe_constantize&.find_by(id: entity_id)
  end
end
