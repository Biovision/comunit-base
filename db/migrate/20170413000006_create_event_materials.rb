class CreateEventMaterials < ActiveRecord::Migration[5.0]
  def up
    unless EventMaterial.table_exists?
      create_table :event_materials do |t|
        t.timestamps
        t.references :event, foreign_key: { on_update: :cascade, on_delete: :cascade }, null: false
        t.boolean :show_on_page, default: true, null: false
        t.string :uuid, null: false
        t.string :name
        t.string :attachment
        t.string :description
      end
    end
  end

  def down
    if EventMaterial.table_exists?
      drop_table :event_materials
    end
  end
end
