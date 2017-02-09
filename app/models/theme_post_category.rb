class ThemePostCategory < ApplicationRecord
  belongs_to :theme, counter_cache: :post_categories_count
  belongs_to :post_category
end
