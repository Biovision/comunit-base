# frozen_string_literal: true

# Helper methods for decisions component
module DecisionsHelper
  # @param [Decision] entity
  # @param [String] text
  # @param [Hash] options
  def admin_decision_link(entity, text = entity&.name, options = {})
    return '' if entity.nil?

    link_to(text, admin_decision_path(id: entity.id), options)
  end

  # @param [Decision] entity
  # @param [String] text
  # @param [Hash] options
  def decision_link(entity, text = entity&.name, options = {})
    return '' if entity.nil?

    link_to(text, decision_path(id: entity.uuid), options)
  end
end
