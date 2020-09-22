# frozen_string_literal: true

# Helper methods for region and country handling
module RegionsHelper
  # @param [Country] entity
  # @param [String] text
  def admin_country_link(entity, text = entity.name)
    link_to(text, admin_country_path(id: entity.id))
  end

  # @param [Region] entity
  # @param [String] text
  # @param [Hash] options
  def admin_region_link(entity, text = entity.name, options = {})
    link_to(text, admin_region_path(id: entity.id), options)
  end

  # @param [Region] entity
  # @param [Hash] options
  def region_image_preview(entity, options = {})
    return '' if entity&.id.nil?

    image_url = entity.data.dig('image', 'preview')

    return '' if image_url.nil?

    default_options = { alt: entity.name }

    image_tag(image_url, default_options.merge(options))
  end

  # @param [Integer] selected_id
  def current_region_for_select(selected_id = 0)
    options = [['Центр', '', { data: { url: root_path } }]]
    Region.visible.with_posts.for_tree.each do |region|
      url = regional_index_path(region_slug: region.long_slug)
      options << [region.short_name, region.id, { data: { url: url } }]
    end

    options_for_select(options, selected_id)
  end

  # @param [Integer] region_id
  # @param [Integer] selected_id
  def child_regions_for_select(region_id, selected_id = 0, slug = '')
    options = []
    if region_id.to_i < 1
      options << ['Центр', '', { data: { url: root_path } }]
    else
      options << ['Все', '', { data: { url: regional_index_path(region_slug: slug) } }]
    end
    Region.visible.with_posts.for_tree(nil, region_id).each do |region|
      url = regional_index_path(region_slug: region.long_slug)
      options << [region.short_name, region.id, { data: { url: url } }]
    end

    options_for_select(options, selected_id)
  end

  # @param [Region] entity
  def region_image_medium(entity)
    unless entity.image.blank?
      versions = "#{entity.image.medium_2x.url} 2x"
      image_tag(entity.image.medium.url, alt: entity.name, srcset: versions)
    end
  end

  # @param [Region] entity
  # @param [Hash] options
  def region_image_small(entity, options = {})
    return '' if entity.image.blank?

    default = { alt: entity.name }
    image_tag(entity.image.small.url, default.merge(options))
  end
end
