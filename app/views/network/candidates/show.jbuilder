json.data do
  json.id @entity.id
  json.type @entity.class.table_name
  json.attributes do
    json.call(@entity, :uuid)
  end
end
