class PopularPosts
  def self.prepare(count = 5)
    {
        week: week(count),
        month: month(count),
        overall: overall(count)
    }
  end

  def self.week(count)
    Post.visible.where('created_at > ?', 7.days.ago).popular.first(count)
  end

  def self.month(count)
    Post.visible.where('created_at > ?', 1.month.ago).popular.first(count)
  end

  def self.overall(count)
    Post.visible.popular.first(count)
  end
end