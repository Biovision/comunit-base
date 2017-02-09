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

  private

  def set_next_priority
    if id.nil? && priority == 1
      self.priority = NewsCategory.maximum(:priority).to_i + 1
    end
  end
end
