class CreateThemes < ActiveRecord::Migration[5.0]
  def up
    unless Theme.table_exists?
      create_table :themes do |t|
        t.timestamps
        t.boolean :locked, default: false, null: false
        t.integer :post_categories_count, limit: 2, default: 0, null: false
        t.integer :news_categories_count, limit: 2, default: 0, null: false
        t.string :name, null: false
        t.string :slug, null: false
      end
    end
  end

  def down
    if Theme.table_exists?
      drop_table :themes
    end
  end
end
