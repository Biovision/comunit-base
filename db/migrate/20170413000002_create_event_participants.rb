class CreateEventParticipants < ActiveRecord::Migration[5.0]
  def up
    unless EventParticipant.table_exists?
      create_table :event_participants do |t|
        t.timestamps
        t.references :event, foreign_key: { on_update: :cascade, on_delete: :cascade }, null: false
        t.references :user, foreign_key: { on_update: :cascade, on_delete: :nullify }
        t.references :agent, foreign_key: { on_update: :cascade, on_delete: :nullify }
        t.inet :ip
        t.boolean :processed, default: false, null: false
        t.string :notice
        t.string :name
        t.string :surname
        t.string :email
        t.string :company
        t.string :phone
        t.text :comment
      end

      add_index :event_participants, :created_at
    end
  end

  def down
    if EventParticipant.table_exists?
      drop_table :event_participants
    end
  end
end
