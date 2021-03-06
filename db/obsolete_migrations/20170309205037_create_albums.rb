class CreateAlbums < ActiveRecord::Migration[5.0]
  def up
    unless Album.table_exists?
      create_table :albums do |t|
        t.timestamps
        t.references :user, foreign_key: { on_update: :cascade, on_delete: :cascade }, null: false
        t.references :region, foreign_key: { on_update: :cascade, on_delete: :nullify }
        t.integer :photos_count, default: 0, null: false
        t.integer :priority, limit: 2, default: 1, null: false
        t.boolean :show_on_front, default: false, null: false
        t.boolean :visible, default: true, null: false
        t.string :uuid, null: false
        t.string :name
        t.string :slug
        t.string :image
        t.text :description
      end
    end
  end

  def down
    if Album.table_exists?
      drop_table :albums
    end
  end
end
