class AddComunitToPrivileges < ActiveRecord::Migration[5.0]
  def up
    unless column_exists?(:privileges, :regional)
      change_table :privileges do |t|
        t.integer :external_id
        t.boolean :regional, default: false, null: false
      end

      insert_records

      Privilege.order('id asc').each { |privilege| privilege.cache_parents! }
      Privilege.order('id desc').each { |privilege| privilege.cache_children! }
    end
  end

  def down
    if column_exists?(:privileges, :regional)
      remove_column :privileges, :regional
      remove_column :privileges, :external_id
    end
  end

  def insert_records
    editors   = Privilege.find_by(slug: 'editors')
    reporters = PrivilegeGroup.create!(slug: 'reporters', name: 'Редакторы новостей')

    Privilege.create!(slug: 'group_manager', name: 'Управляющий группами')
    Privilege.create!(slug: 'feedback_manager', name: 'Орготдел')
    Privilege.create!(slug: 'teams_manager', name: 'Управляющий «Лицами»')

    privilege = Privilege.create!(slug: 'head', name: 'Руководитель')
    editors.add_privilege(privilege)
    reporters.add_privilege(privilege)

    privilege = Privilege.create!(parent: privilege, slug: 'regional_head', name: 'Региональный руководитель', regional: true)
    editors.add_privilege(privilege)
    reporters.add_privilege(privilege)

    privilege = Privilege.find_by(slug: 'chief_editor')
    privilege.update! name: 'Главный редактор центра'
    reporters.add_privilege(privilege)

    child = Privilege.create!(parent: privilege, slug: 'deputy_chief_editor', name: 'Заместитель главного редактора центра')
    editors.add_privilege(child)
    reporters.add_privilege(child)

    editors.add_privilege(child.children.create!(slug: 'editor', name: 'Редактор центра'))
    reporters.add_privilege(child.children.create!(slug: 'reporter', name: 'Корреспондент центра'))
    reporters.add_privilege(child.children.create!(slug: 'civic_reporter', name: 'Народный корреспондент центра'))

    privilege = Privilege.create!(slug: 'regional_chief_editor', name: 'Главный редактор региона', regional: true)
    child     = Privilege.create!(parent: privilege, slug: 'regional_deputy_chief_editor', name: 'Заместитель главного редактора региона', regional: true)
    editors.add_privilege(child)
    reporters.add_privilege(child)

    editors.add_privilege(child.children.create!(slug: 'regional_editor', name: 'Редактор региона', regional: true))
    reporters.add_privilege(child.children.create!(slug: 'regional_reporter', name: 'Корреспондент региона', regional: true))
    reporters.add_privilege(child.children.create!(slug: 'regional_civic_reporter', name: 'Народный корреспондент региона', regional: true))
  end
end
