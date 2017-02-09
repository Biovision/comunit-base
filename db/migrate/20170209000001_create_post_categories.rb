class CreatePostCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :post_categories do |t|
      t.timestamps
      t.integer :external_id
      t.integer :parent_id
      t.integer :priority, default: 1, null: false
      t.integer :items_count, default: 0, null: false
      t.boolean :locked, default: false, null: false
      t.boolean :deleted, default: false, null: false
      t.boolean :visible, default: true, null: false
      t.string :name, null: false
      t.string :slug, null: false
      t.string :parents_cache, default: "", null: false
      t.integer :children_cache, default: [], null: false, array: true
    end
  end
end
