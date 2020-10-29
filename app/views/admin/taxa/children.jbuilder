json.data @collection do |entity|
  json.partial! 'admin/taxa/taxon', locals: { entity: entity, user: @user }
end
