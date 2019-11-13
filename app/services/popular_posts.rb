# frozen_string_literal: true

# Getting popular posts
class PopularPosts
  def self.post_type_ids
    PostType.where(slug: %w[news article]).pluck(:id)
  end

  def self.prepare(count = 5)
    {
      week: week(count),
      month: month(count),
      overall: overall(count)
    }
  end

  def self.week(count)
    Post.visible.where(post_type_id: post_type_ids).where('created_at > ?', 7.days.ago).popular.first(count)
  end

  def self.month(count)
    Post.visible.where(post_type_id: post_type_ids).where('created_at > ?', 1.month.ago).popular.first(count)
  end

  def self.overall(count)
    Post.visible.where(post_type_id: post_type_ids).popular.first(count)
  end
end