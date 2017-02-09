class CreateThemePostCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :theme_post_categories do |t|
      t.references :theme, foreign_key: true, null: false, on_update: :cascade, on_delete: :cascade
      t.references :post_category, foreign_key: true, null: false, on_update: :cascade, on_delete: :cascade
    end
  end
end
