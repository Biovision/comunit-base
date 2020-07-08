json.data @entity.poll_users.list_for_administration do |entity|
  json.id entity.id
  json.type entity.class.table_name
  json.attributes do
    json.(entity, :user_id, :poll_id)
  end
  json.meta do
    json.html render(partial: 'admin/poll_users/entity/in_list', formats: [:html], locals: { entity: entity })
  end
end
