# frozen_string_literal: true

# Synchronize entity with main site
class NetworkEntitySyncJob < ApplicationJob
  queue_as :default

  # @param [String] entity_class
  # @param [Integer] entity_id
  # @param [String] site_id
  def perform(entity_class, entity_id, site_id = nil)
    handler = handler_from_string(entity_class)

    return if handler.nil?

    handler.entity = model_from_string(entity_class, entity_id)
    push handler, site_id
  end

  private

  # @param [Comunit::Network::Handler] handler
  # @param [String] site_id
  def push(handler, site_id)
    if Comunit::Network::Handler.central_site?
      sites(site_id).each do |site|
        handler.site = site
        handler.push if handler.sync?
      end
    else
      handler.push
    end
  end

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

  # @param [String] site_id
  def sites(site_id)
    if site_id.nil?
      Site.active.order('id asc')
    else
      Site.active.where(uuid: site_id)
    end
  end
end
