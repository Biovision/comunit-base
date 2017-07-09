json.data @collection do |entity|
  json.id entity.id
  json.type entity.class.table_name
  json.attributes do
    json.(entity, :name, :long_slug, :children_cache)
  end
  json.meta do
    json.html_chunk render(partial: 'admin/news/regions/list_item', formats: [:html], locals: { region: entity })
  end
end