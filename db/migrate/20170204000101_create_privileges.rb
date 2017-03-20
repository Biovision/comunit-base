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

      Privilege.create(slug: 'administrator', name: 'Администратор')
      Privilege.create(slug: 'moderator', name: 'Модератор')
      Privilege.create(slug: 'metrics_manager', name: 'Аналитик метрик')
      Privilege.create(slug: 'group_manager', name: 'Управляющий группами')
      Privilege.create(slug: 'feedback_manager', name: 'Орготдел')
      Privilege.create(slug: 'head', name: 'Руководитель')
      Privilege.create(slug: 'chief_editor', name: 'Главный редактор центра')
    end
  end

  def down
    if Privilege.table_exists?
      drop_table :privileges
    end
  end
end
