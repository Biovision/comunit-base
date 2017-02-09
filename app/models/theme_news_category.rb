class ThemeNewsCategory < ApplicationRecord
  belongs_to :theme, counter_cache: :news_categories_count
  belongs_to :news_category
end
