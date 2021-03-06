class Theme < ApplicationRecord
  has_many :theme_post_categories, dependent: :destroy
  # has_many :theme_news_categories, dependent: :destroy
  has_many :post_categories, through: :theme_post_categories
  # has_many :news_categories, through: :theme_news_categories

  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug

  scope :ordered_by_name, -> { order 'name asc' }

  def self.page_for_administration
    ordered_by_name
  end

  def self.entity_parameters
    %i[name slug]
  end

  # @param [Integer] limit
  # @param [Region] region
  # @param [Integer] page
  def entries(limit = 5, region = nil, page = 1)
    Post.in_region(region).with_category_ids(post_category_ids).visible.recent.page(page).per(limit)
  end
end
