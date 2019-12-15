json.data do
  json.id @entity.id
  json.type @entity.class.table_name
  if @entity.respond_to?(:uuid)
    json.attributes do
      json.call(@entity, :uuid)
    end
  end
end
if @entity.respond_to?(:sync_state)
  json.meta do
    json.sync_state @entity.sync_state
  end
end
