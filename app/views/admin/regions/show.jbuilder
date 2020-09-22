json.data do
  json.partial! @entity
  json.relationships do
    json.children @entity.child_items.ordered_by_name.only_with_ids(component_handler.allowed_region_ids) do |child|
      json.partial! child
    end
  end
end
