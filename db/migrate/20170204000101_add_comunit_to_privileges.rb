# frozen_string_literal: true

# Add regional flag to privileges and privileges for common site
class AddComunitToPrivileges < ActiveRecord::Migration[5.2]
  def up
    editors   = PrivilegeGroup.find_by(slug: 'editors') || PrivilegeGroup.create!(slug: 'editors', name: 'Редакторы')
    reporters = PrivilegeGroup.create!(slug: 'reporters', name: 'Редакторы новостей')

    Privilege.create(slug: 'group_manager', name: 'Управляющий группами')
    Privilege.create(slug: 'feedback_manager', name: 'Орготдел')
    Privilege.create(slug: 'teams_manager', name: 'Управляющий «Лицами»')
    Privilege.create(slug: 'blogger', name: 'Блогер')

    privilege = Privilege.create(slug: 'head', name: 'Руководитель')
    editors.add_privilege(privilege)
    reporters.add_privilege(privilege)

    privilege = Privilege.create(parent: privilege, slug: 'regional_head', name: 'Региональный руководитель', regional: true)
    editors.add_privilege(privilege)
    reporters.add_privilege(privilege)

    privilege = Privilege.find_by(slug: 'chief_editor') || Privilege.create!(slug: 'chief_editor', name: 'Главный редактор центра')
    privilege.update! name: 'Главный редактор центра'
    reporters.add_privilege(privilege)

    child = Privilege.create(parent: privilege, slug: 'deputy_chief_editor', name: 'Заместитель главного редактора центра')
    editors.add_privilege(child)
    reporters.add_privilege(child)

    editors.add_privilege(child.child_privileges.create(slug: 'editor', name: 'Редактор центра'))
    reporters.add_privilege(child.child_privileges.create(slug: 'reporter', name: 'Корреспондент центра'))
    reporters.add_privilege(child.child_privileges.create(slug: 'civic_reporter', name: 'Народный корреспондент центра'))

    privilege = Privilege.create(slug: 'regional_chief_editor', name: 'Главный редактор региона', regional: true)
    child     = Privilege.create(parent: privilege, slug: 'regional_deputy_chief_editor', name: 'Заместитель главного редактора региона', regional: true)
    editors.add_privilege(child)
    reporters.add_privilege(child)

    editors.add_privilege(child.child_privileges.create(slug: 'regional_editor', name: 'Редактор региона', regional: true))
    reporters.add_privilege(child.child_privileges.create(slug: 'regional_reporter', name: 'Корреспондент региона', regional: true))
    reporters.add_privilege(child.child_privileges.create(slug: 'regional_civic_reporter', name: 'Народный корреспондент региона', regional: true))
  end

  def down
    # No rollback needed
  end
end
