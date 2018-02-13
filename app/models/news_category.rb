class NewsCategory < ApplicationRecord
  include Toggleable
  include RequiredUniqueName

  toggleable :visible

  has_many :news

  after_initialize :set_next_priority

  before_validation { self.slug = Canonizer.transliterate(name.to_s) if slug.blank? }

  validates_presence_of :slug, :priority
  validates_uniqueness_of :slug

  scope :ordered_by_priority, -> { order 'priority asc' }
  scope :visible, -> { where visible: true, deleted: false }
  scope :for_editor, ->(user) { where(deleted: false).ordered_by_priority }

  def self.page_for_administration
    ordered_by_priority
  end

  def self.page_for_visitors
    visible.ordered_by_priority
  end

  def self.entity_parameters
    %i(name slug priority visible)
  end

  # @param [News] news
  def has_news?(news)
    news.news_category == self
  end

  def full_title
    name
  end

  # @param [Integer] delta
  def change_priority(delta)
    new_priority = priority + delta
    adjacent     = NewsCategory.find_by(priority: new_priority)
    if adjacent.is_a?(NewsCategory) && (adjacent.id != id)
      adjacent.update!(priority: priority)
    end
    self.update(priority: new_priority)

    NewsCategory.ordered_by_priority.map { |e| [e.id, e.priority] }.to_h
  end

  private

  def set_next_priority
    if id.nil? && priority == 1
      self.priority = NewsCategory.maximum(:priority).to_i + 1
    end
  end
end
