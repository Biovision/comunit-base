json.id entity.id
json.type entity.class.table_name
json.attributes do
  json.call(entity, :name, :children_cache, :parents_cache)
end
json.meta do
  json.user_linked entity.user?(user) unless user.nil?
end
json.links do
  json.self admin_taxon_path(id: entity.id)
  json.children children_admin_taxon_path(id: entity.id, user_id: user&.id)
  json.user user_admin_taxon_path(id: entity.id, user_id: user.id) unless user.nil?
end
