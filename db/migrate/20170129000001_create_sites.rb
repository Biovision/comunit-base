class CreateSites < ActiveRecord::Migration[5.0]
  def up
    unless Site.table_exists?
      create_table :sites do |t|
        t.timestamps
        t.boolean :active, null: false, default: true
        t.boolean :deleted, null: false, default: false
        t.boolean :has_regions, null: false, default: false
        t.integer :users_count, null: false, default: 0
        t.string :name, null: false
        t.string :host, null: false
        t.string :image
        t.string :description
      end
    end
  end

  def down
    if Site.table_exists?
      drop_table :sites
    end
  end
end
