json.data do
  json.partial! 'admin/taxa/taxon', locals: { entity: @entity, user: @user }
end
