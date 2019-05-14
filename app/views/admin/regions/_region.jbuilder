json.id region.id
json.type region.class.table_name
json.attributes do
  json.call(region, :parent_id, :name, :parents_cache, :data, :priority)
end
json.meta do
  json.child_count region.children_cache.count
end
json.links do
  json.self admin_region_path(id: region.id, format: :json)
end
