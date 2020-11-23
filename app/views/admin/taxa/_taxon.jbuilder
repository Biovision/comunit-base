json.id entity.id
json.type entity.class.table_name
json.attributes do
  json.call(entity, :name, :children_cache, :parents_cache)
end
json.meta do
  json.user_linked entity.user?(user) unless user.nil?
  json.post_group_linked entity.post_group?(post_group) unless post_group.nil?
  json.post_linked entity.post?(post) unless post.nil?
end
json.links do
  json.self admin_taxon_path(id: entity.id)
  json.children children_admin_taxon_path(id: entity.id, user_id: user&.id, post_group_id: post_group&.id, post_id: post&.id)
  json.user user_admin_taxon_path(id: entity.id, user_id: user.id) unless user.nil?
  json.post_group post_group_admin_taxon_path(id: entity.id, post_group_id: post_group.id) unless post_group.nil?
end
