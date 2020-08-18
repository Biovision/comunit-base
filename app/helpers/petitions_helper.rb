# frozen_string_literal: true

# Helper methods for petitions component
module PetitionsHelper
  # @param [Petition] entity
  # @param [String] text
  # @param [Hash] options
  def admin_petition_link(entity, text = entity&.title, options = {})
    return '' if entity.nil?

    link_to(text, admin_petition_path(id: entity.id), options)
  end

  # @param [Petition] entity
  # @param [String] text
  # @param [Hash] options
  def petition_link(entity, text = entity&.title, options = {})
    return '' if entity.nil?

    link_to(text, petition_path(id: entity.id), options)
  end
end
