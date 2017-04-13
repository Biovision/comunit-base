class CreateEventSponsors < ActiveRecord::Migration[5.0]
  def up
    unless EventSponsor.table_exists?
      create_table :event_sponsors do |t|
        t.timestamps
        t.references :event, foreign_key: true, null: false, on_update: :cascade, on_delete: :cascade
        t.integer :priority, limit: 2, null: false, default: 1
        t.string :image
        t.string :name, null: false
        t.string :url
      end
    end
  end

  def down
    if EventSponsor.table_exists?
      drop_table :event_sponsors
    end
  end
end
