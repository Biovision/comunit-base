json.id region.id
json.type region.class.table_name
json.attributes do
  json.(region, :parent_id, :name, :short_name, :priority, :slug, :long_slug)
end
json.links do
  json.self region_path(id: region.id, format: :json)
  json.children children_region_path(id: region.id)
end
json.meta do
  json.child_count region.children_cache.count
end