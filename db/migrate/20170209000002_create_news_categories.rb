class CreateNewsCategories < ActiveRecord::Migration[5.0]
  def up
    unless NewsCategory.table_exists?
      create_table :news_categories do |t|
        t.timestamps
        t.integer :external_id
        t.integer :priority, limit: 2, default: 1, null: false
        t.integer :items_count, default: 0, null: false
        t.boolean :locked, default: false, null: false
        t.boolean :deleted, default: false, null: false
        t.boolean :visible, default: true, null: false
        t.string :name, null: false
        t.string :slug, null: false
      end
    end
  end

  def down
    if NewsCategory.table_exists?
      drop_table :news_categories
    end
  end
end
