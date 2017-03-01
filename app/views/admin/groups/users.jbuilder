json.data do
  json.users @collection do |user|
    json.type user.class.table_name
    json.id user.id
    json.attributes do
      json.(user, :slug, :screen_name, :profile_name)
    end
    json.html render(partial: 'admin/groups/users/user', formats: [:html], locals: { entity: user, group: @entity } )
  end
end
json.partial! 'shared/pagination', locals: { collection: @collection }
