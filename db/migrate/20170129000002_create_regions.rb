class CreateRegions < ActiveRecord::Migration[5.0]
  def up
    unless Region.table_exists?
      create_table :regions do |t|
        t.timestamps
        t.boolean :visible, null: false, default: true
        t.boolean :locked, default: false, null: false
        t.integer :users_count, default: 0, null: false
        t.integer :news_count, default: 0, null: false
        t.string :slug, null: false
        t.string :name, null: false
        t.string :image
        t.string :header_image
      end
    end
  end

  def down
    if Region.table_exists?
      drop_table :regions
    end
  end
end
