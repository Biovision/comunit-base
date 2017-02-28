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
    Entry.not_deleted.public_entries.since(7.days.ago).popular.first(count)
  end

  # @param [Integer] count
  def self.month(count)
    Entry.not_deleted.public_entries.since(1.month.ago).popular.first(count)
  end

  # @param [Integer] count
  def self.overall(count)
    Entry.not_deleted.public_entries.popular.first(count)
  end
end