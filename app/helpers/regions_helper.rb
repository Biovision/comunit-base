module RegionsHelper
  # @param [Region] entity
  def admin_region_link(entity)
    link_to(entity.name, admin_region_path(entity.id))
  end

  def regions_for_select(user = nil)
    options = [[t(:not_set), '']]
    if user.is_a?(User)
      allowed_ids = UserPrivilege.where(user: user).pluck(:region_id).uniq
      if allowed_ids.any?
        selection = Region.where(id: allowed_ids).for_tree
      else
        selection = Region.for_tree
      end
    else
      selection = Region.for_tree
    end
    selection.each { |r| options << [r.name, r.id] }
    options
  end

  def current_region_for_select(selected_id)
    options = [['Центр', '', { data: { url: root_path } }]]
    Region.visible.for_tree.each do |region|
      url = regional_index_path(region_slug: region.long_slug)
      options << [region.name, region.id, { data: { url: url } }]
    end

    options_for_select(options, selected_id)
  end

  # @param [Region] entity
  def region_image_preview(entity)
    unless entity.image.blank?
      versions = '' #"#{entity.image.preview_2x.url} 2x"
      image_tag(entity.image.preview.url, alt: entity.name, srcset: versions)
    end
  end

  # @param [Region] entity
  def region_image_medium(entity)
    unless entity.image.blank?
      versions = '' #"#{entity.image.medium_2x.url} 2x"
      image_tag(entity.image.medium.url, alt: entity.name, srcset: versions)
    end
  end
end
