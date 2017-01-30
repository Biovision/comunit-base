module RegionsHelper
  def regions_for_select
    options = [[t(:not_set), '']]
    Region.ordered_by_slug.each { |r| options << ["#{r.slug}: #{r.name}", r.id] }
    options
  end

  def current_region_for_select(selected_id)
    options = [['Центр', '', { data: { url: root_url(subdomain: '') } }]]
    Region.ordered_by_name.each do |region|
      options << [region.name, region.id, {data: {url: root_url(subdomain: region.slug) } }]
    end

    options_for_select(options, selected_id)
  end
end
