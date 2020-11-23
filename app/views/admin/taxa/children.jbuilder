json.data @collection do |entity|
  json.partial! 'admin/taxa/taxon', locals: { entity: entity, user: @user, post_group: @post_group, post: @post }
end
