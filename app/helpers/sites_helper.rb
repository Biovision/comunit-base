# frozen_string_literal: true

# Helper methods for sites handling
module SitesHelper
  # @param [Site] entity
  def admin_site_link(entity)
    link_to(entity.name, admin_site_path(id: entity.id))
  end

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

  # @param [Post] post
  # @param [Site] site
  def post_state_on_site(post, site)
    return t('activerecord.attributes.site_post.states.original') if post.site == site

    link = site.post_state(post)

    return '' if link.nil?

    t("activerecord.attributes.site_post.states.#{link.state}")
  end
end
