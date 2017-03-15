class CreatePhotos < ActiveRecord::Migration[5.0]
  def up
    unless Photo.table_exists?
      create_table :photos do |t|
        t.timestamps
        t.references :album, foreign_key: true
        t.integer :priority, default: 1, null: false
        t.string :uuid, null: false
        t.string :name
        t.string :image
        t.text :description
      end
    end
  end

  def down
    if Photo.table_exists?
      drop_table :photos
    end
  end
end
