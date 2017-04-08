json.data @regional_news do |post|
  json.partial! 'post_preview', post: post
end
json.links do
  json.next(index_regional_news_path(page: current_page + 1, region_id: param_from_request(:region_id)))
end