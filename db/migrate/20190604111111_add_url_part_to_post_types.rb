# frozen_string_literal: true

# Add url_part to post_types table
class AddUrlPartToPostTypes < ActiveRecord::Migration[5.2]
  def up
    return if column_exists? :post_types, :url_part

    add_column :post_types, :url_part, :string

    mapping = { blog_post: 'blog_posts', article: 'articles', news: 'news' }
    mapping.each do |slug, url_part|
      PostType.find_by(slug: slug)&.update!(url_part: url_part)
    end
  end

  def down
    # No rollback needed
  end
end
