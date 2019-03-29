class PopularEntries
  # @param [Integer] count
  def self.prepare(count = 5)
    {
        week: week(count),
        month: month(count),
        overall: overall(count)
    }
  end

  # @param [Integer] count
  def self.week(count)
    Post.of_type('blog_post').visible.posted_after(7.days.ago).popular.first(count)
  end

  # @param [Integer] count
  def self.month(count)
    Post.of_type('blog_post').visible.posted_after(1.month.ago).popular.first(count)
  end

  # @param [Integer] count
  def self.overall(count)
    Post.of_type('blog_post').visible.popular.first(count)
  end
end