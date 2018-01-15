class CreateEventSpeakers < ActiveRecord::Migration[5.0]
  def up
    unless EventSpeaker.table_exists?
      create_table :event_speakers do |t|
        t.timestamps
        t.references :event, foreign_key: { on_update: :cascade, on_delete: :cascade }, null: false
        t.integer :priority, limit: 2, null: false, default: 1
        t.boolean :visible, default: true, null: false
        t.string :image
        t.string :name, null: false
        t.string :occupation
      end
    end
  end

  def down
    if EventSpeaker.table_exists?
      drop_table :event_speakers
    end
  end
end
