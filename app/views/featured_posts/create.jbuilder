json.data do
  json.id @entity.id
  json.type @entity.class.table_name
  json.attributes do
    json.call(@entity, :post_id, :priority)
  end
  json.meta do
    json.html render(partial: 'admin/featured_posts/entity/in_list', formats: [:html], locals: { entity: @entity })
  end
end
