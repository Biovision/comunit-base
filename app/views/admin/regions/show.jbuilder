json.data do
  json.partial! @entity
  json.relationships do
    json.children @entity.child_regions do |child|
      json.partial! child
    end
  end
end