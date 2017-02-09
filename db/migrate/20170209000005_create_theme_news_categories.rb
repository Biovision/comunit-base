class CreateThemeNewsCategories < ActiveRecord::Migration[5.0]
  def up
    unless ThemeNewsCategory.table_exists?
      create_table :theme_news_categories do |t|
        t.references :theme, foreign_key: true, null: false, on_update: :cascade, on_delete: :cascade
        t.references :news_category, foreign_key: true, null: false, on_update: :cascade, on_delete: :cascade
      end
    end
  end

  def down
    if ThemeNewsCategory.table_exists?
      drop_table :theme_news_categories
    end
  end
end
