class CreateCities < ActiveRecord::Migration[5.0]
  def up
    unless City.table_exists?
      create_table :cities do |t|
        t.timestamps
        t.references :region, foreign_key: true, null: false, on_update: :cascade, on_delete: :cascade
        t.boolean :visible, default: true, null: false
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
    if City.table_exists?
      drop_table :cities
    end
  end
end
