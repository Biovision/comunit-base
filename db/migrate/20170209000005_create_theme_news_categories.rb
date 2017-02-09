class CreateThemeNewsCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :theme_news_categories do |t|
      t.references :theme, foreign_key: true, null: false, on_update: :cascade, on_delete: :cascade
      t.references :news_category, foreign_key: true, null: false, on_update: :cascade, on_delete: :cascade
    end
  end
end
