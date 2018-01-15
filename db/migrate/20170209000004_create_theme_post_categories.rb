class CreateThemePostCategories < ActiveRecord::Migration[5.0]
  def up
    unless ThemePostCategory.table_exists?
      create_table :theme_post_categories do |t|
        t.references :theme, foreign_key: { on_update: :cascade, on_delete: :cascade }, null: false
        t.references :post_category, foreign_key: { on_update: :cascade, on_delete: :cascade }, null: false
      end
    end
  end

  def down
    if ThemePostCategory.table_exists?
      drop_table :theme_post_categories
    end
  end
end
