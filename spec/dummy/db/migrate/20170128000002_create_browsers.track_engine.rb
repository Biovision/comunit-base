# This migration comes from track_engine (originally 20170129000001)
class CreateBrowsers < ActiveRecord::Migration[5.0]
  def up
    unless Browser.table_exists?
      create_table :browsers do |t|
        t.timestamps
        t.boolean :bot, null: false, default: false
        t.boolean :mobile, null: false, default: false
        t.boolean :active, null: false, default: true
        t.boolean :locked, null: false, default: false
        t.boolean :deleted, null: false, default: false
        t.integer :agents_count, null: false, default: 0
        t.string :name, null: false
      end
    end
  end

  def down
    if Browser.table_exists?
      drop_table :browsers
    end
  end
end
