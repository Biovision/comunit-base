class CreateTeamPrivileges < ActiveRecord::Migration[5.0]
  def up
    unless TeamPrivilege.table_exists?
      create_table :team_privileges do |t|
        t.timestamps
        t.references :team, foreign_key: true, null: false, on_update: :cascade, on_delete: :cascade
        t.references :privilege, foreign_key: true, null: false, on_update: :cascade, on_delete: :cascade
      end
    end
  end

  def down
    if TeamPrivilege.table_exists?
      drop_table :team_privileges
    end
  end
end
