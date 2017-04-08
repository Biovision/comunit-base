json.type post.class.table_name
json.id post.id
json.html render(partial: 'index/frontpage_posts/preview', formats: [:html], locals: { post: post } )