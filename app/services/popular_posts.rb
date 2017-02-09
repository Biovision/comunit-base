class PopularPosts
  def self.prepare(count = 5)
    {
        week: week(count),
        month: month(count),
        overall: overall(count)
    }
  end

  def self.week(count)
    collection = []
    collection += News.visible.where('created_at > ?', 7.days.ago).popular.first(count)
    collection += Post.visible.where('created_at > ?', 7.days.ago).popular.first(count)
    sorted(collection).first(count)
  end

  def self.month(count)
    collection = []
    collection += News.visible.where('created_at > ?', 1.month.ago).popular.first(count)
    collection += Post.visible.where('created_at > ?', 1.month.ago).popular.first(count)
    sorted(collection).first(count)
  end

  def self.overall(count)
    collection = []
    collection += News.visible.popular.first(count)
    collection += Post.visible.popular.first(count)
    sorted(collection).first(count)
  end

  private

  def self.sorted(collection)
    collection.sort { |a, b| a.view_count <=> b.view_count }.reverse
  end
end