class CreatePrivileges < ActiveRecord::Migration[5.0]
  def up
    unless Privilege.table_exists?
      create_table :privileges do |t|
        t.timestamps
        t.integer :external_id
        t.integer :parent_id
        t.boolean :locked, default: false, null: false
        t.boolean :deleted, default: false, null: false
        t.boolean :regional, default: false, null: false
        t.integer :priority, limit: 2, default: 1, null: false
        t.integer :users_count, default: 0, null: false
        t.string :parents_cache, default: '', null: false
        t.integer :children_cache, default: [], null: false, array: true
        t.string :name, null: false
        t.string :slug, null: false
        t.string :description, default: '', null: false
      end
    end
  end

  def down
    if Privilege.table_exists?
      drop_table :privileges
    end
  end
end
