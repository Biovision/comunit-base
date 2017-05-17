class AddComunitToUserPrivileges < ActiveRecord::Migration[5.0]
  def up
    unless column_exists?(:user_privileges, :region_id)
      add_reference :user_privileges, :region, foreign_key: true, on_update: :cascade, on_delete: :cascade
    end
  end

  def down
    if column_exists?(:user_privileges, :region_id)
      remove_column :user_privileges, :region_id
    end
  end
end
