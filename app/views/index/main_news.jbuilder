json.data @main_news do |post|
  json.partial! 'post_preview', post: post
end
json.links do
  json.next(index_main_news_path(page: current_page + 1))
end