json.data do
  json.users @collection do |user|
    json.type user.class.table_name
    json.id user.id
    json.attributes do
      json.(user, :slug, :screen_name, :profile_name)
    end
    json.image_tag profile_avatar(user)
    json.links do
      json.profile user_profile_path(slug: user.slug)
    end
  end
end
json.partial! 'shared/pagination', locals: { collection: @collection }
