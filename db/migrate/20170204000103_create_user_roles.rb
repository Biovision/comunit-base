class CreateUserRoles < ActiveRecord::Migration[5.0]
  def up
    unless UserRole.table_exists?
      create_table :user_roles do |t|
        t.timestamps
        t.references :user, foreign_key: true, null: false, on_update: :cascade, on_delete: :cascade
        t.integer :role, limit: 2, null: false
      end
    end
  end

  def down
    if UserRole.table_exists?
      drop_table :user_roles
    end
  end
end
