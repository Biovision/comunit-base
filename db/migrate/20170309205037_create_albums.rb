class CreateAlbums < ActiveRecord::Migration[5.0]
  def up
    unless Album.table_exists?
      create_table :albums do |t|
        t.timestamps
        t.references :user, foreign_key: true, null: false, on_update: :cascade, on_delete: :cascade
        t.references :region, foreign_key: true, null: false, on_update: :cascade, on_delete: :nullify
        t.integer :photos_count, default: 0, null: false
        t.boolean :show_on_front, default: false, null: false
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
