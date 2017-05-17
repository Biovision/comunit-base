class AddComunitToPrivileges < ActiveRecord::Migration[5.0]
  def up
    unless column_exists?(:privileges, :regional)
      change_table :privileges do |t|
        t.integer :external_id
        t.boolean :regional, default: false, null: false
      end

      Privilege.create(slug: 'group_manager', name: 'Управляющий группами')
      Privilege.create(slug: 'feedback_manager', name: 'Орготдел')
      Privilege.create(slug: 'teams_manager', name: 'Управляющий «Лицами»')
      Privilege.create(slug: 'head', name: 'Руководитель')
    end
  end

  def down
    if column_exists?(:privileges, :regional)
      remove_column :privileges, :regional
      remove_column :privileges, :external_id
    end
  end
end
