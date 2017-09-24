class AddBloggerPrivilege < ActiveRecord::Migration[5.1]
  def up
    privilege = Privilege.find_by(slug: 'blogger')
    if privilege.nil?
      privilege = Privilege.create(slug: 'blogger', name: 'Блогер')
    end

    criteria = { privilege_id: privilege.id }

    User.where(verified: true).order('id asc').pluck(:id) do |user_id|
      criteria[:user_id] = user_id
      UserPrivilege.find_or_create_by(criteria)
    end
  end

  def down
  #   Обратно менять смысла нет
  end
end
