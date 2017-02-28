class CreateGroups < ActiveRecord::Migration[5.0]
  def up
    unless Group.table_exists?
      create_table :groups do |t|
        t.timestamps
        t.integer :users_count, default: 0, null: false
        t.string :name, null: false
        t.string :slug, null: false
        t.string :description, default: '', null: false
      end
    end
  end

  def down
    if Group.table_exists?
      drop_table :groups
    end
  end
end
