json.data @main_news do |post|
  json.partial! 'post_preview', post: post
  json.meta do
    json.html render(partial: 'posts/preview', formats: [:html], locals: { entity: post })
  end
end
json.links do
  json.next(index_main_news_path(page: current_page + 1))
end