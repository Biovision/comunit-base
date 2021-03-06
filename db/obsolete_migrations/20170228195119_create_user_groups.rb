class CreateUserGroups < ActiveRecord::Migration[5.0]
  def up
    unless UserGroup.table_exists?
      create_table :user_groups do |t|
        t.timestamps
        t.references :user, foreign_key: { on_update: :cascade, on_delete: :cascade }, null: false
        t.references :group, foreign_key: { on_update: :cascade, on_delete: :cascade }, null: false
      end
    end
  end

  def down
    if UserGroup.table_exists?
      drop_table :user_groups
    end
  end
end
