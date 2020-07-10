# frozen_string_literal: true

# Helper methods for campaigns component
module CampaignsHelper
  # @param [Campaign] entity
  # @param [String] text
  # @param [Hash] options
  def admin_campaign_link(entity, text = entity&.name, options = {})
    return '' if entity.nil?

    link_to(text, admin_campaign_path(id: entity.id), options)
  end

  # @param [PoliticalForce] entity
  # @param [String] text
  # @param [Hash] options
  def admin_political_force_link(entity, text = entity&.name, options = {})
    return '' if entity.nil?

    link_to(text, admin_political_force_path(id: entity.id), options)
  end

  # @param [Campaign] entity
  # @param [String] text
  # @param [Hash] options
  def campaign_link(entity, text = entity&.name, options = {})
    return '' if entity.nil?

    link_to(text, campaign_path(id: entity.slug), options)
  end

  # @param [Candidate] entity
  # @param [String] text
  # @param [Hash] options
  def admin_candidate_link(entity, text = entity&.full_name(true), options = {})
    return '' if entity.nil?

    link_to(text, admin_candidate_path(id: entity.id), options)
  end

  # @param [Candidate] entity
  # @param [String] text
  # @param [Hash] options
  def candidate_link(entity, text = entity&.full_name, options = {})
    return '' if entity.nil?

    parameters = { id: entity.campaign.slug, candidate_id: entity.id }

    link_to(text, candidate_campaign_path(parameters), options)
  end

  # @param [String] heading
  def political_forces_for_select(heading = '')
    result = []
    result << [heading, ''] unless heading.blank?
    PoliticalForce.list_for_visitors.each do |item|
      result << [item.name, item.id]
    end

    result
  end
end
