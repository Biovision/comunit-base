module RegionsHelper
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

  # @param [Integer] selected_id
  def current_region_for_select(selected_id = 0)
    options = [['Центр', '', { data: { url: root_path } }]]
    Region.visible.for_tree.each do |region|
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
    Region.visible.for_tree(region_id).each do |region|
      url = regional_index_path(region_slug: region.long_slug)
      options << [region.short_name, region.id, { data: { url: url } }]
    end

    options_for_select(options, selected_id)
  end
end
