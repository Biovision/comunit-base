class CreateEventPrograms < ActiveRecord::Migration[5.0]
  def up
    unless EventProgram.table_exists?
      create_table :event_programs do |t|
        t.timestamps
        t.references :event, foreign_key: { on_update: :cascade, on_delete: :cascade }, null: false
        t.integer :day_number, limit: 2, null: false, default: 1
        t.string :place
        t.text :body, null: false
      end
    end
  end

  def down
    if EventProgram.table_exists?
      drop_table :event_programs
    end
  end
end
