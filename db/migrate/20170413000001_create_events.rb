class CreateEvents < ActiveRecord::Migration[5.0]
  def up
    unless Event.table_exists?
      create_table :events do |t|
        t.timestamps
        t.date :start_date
        t.integer :day_count, limit: 2, default: 1, null: false
        t.integer :price, default: 0, null: false
        t.integer :event_participants_count, default: 0, null: false
        t.boolean :visible, default: true, null: false
        t.boolean :active, default: true, null: false
        t.boolean :locked, default: false, null: false
        t.string :name, null: false
        t.string :slug
        t.string :image
        t.string :address
        t.string :coordinates
        t.text :lead
        t.text :body, null: false
      end
    end
  end

  def down
    if Event.table_exists?
      drop_table :events
    end
  end
end
