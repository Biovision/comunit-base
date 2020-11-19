json.data @collection do |entity|
  json.id entity.id
  json.type entity.class.table_name
  json.attributes do
    json.call(entity, :name, :taxon_type_id, :object_count)
  end
  json.meta do
    json.taxon_type entity.taxon_type.name
    json.checked @entity.taxon?(entity)
    json.url taxon_admin_post_group_path(id: @entity.id, taxon_id: entity.id)
  end
end
