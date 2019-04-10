# frozen_string_literal: true

# Add reference to regions from privilege
class AddRegionToUserPrivileges < ActiveRecord::Migration[5.2]
  def up
    return if column_exists?(:user_privileges, :region_id)

    add_reference :user_privileges, :region, foreign_key: { on_update: :cascade, on_delete: :cascade }
  end

  def down
    # No rollback needed
  end
end
