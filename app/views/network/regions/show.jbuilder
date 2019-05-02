json.data do
  json.id @entity.id
  json.type @entity.class.table_name
end
