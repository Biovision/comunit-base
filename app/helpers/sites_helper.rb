# frozen_string_literal: true

# Helper methods for sites handling
module SitesHelper
  def sites_for_filter
    options = [[t(:not_set), '']]
    Site.min_version.list_for_administration.each do |site|
      options << [site.host, site.id]
    end

    options
  end

  # @param [Site] entity
  # @param [String] text
  # @param [Hash] options
  def site_link(entity, text = entity.name, options = nil)
    options ||= { rel: 'external nofollow noopener noreferrer', target: '_blank' }
    link_to(text, entity.host, options)
  end

  # @param [Site] entity
  # @param [Hash] options
  def site_image(entity, options = {})
    return '' if entity.image.blank?

    default_options = { alt: '' }

    image_tag(entity.image.preview.url, default_options.merge(options))
  end
end
