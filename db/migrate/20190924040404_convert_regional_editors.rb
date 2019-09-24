# frozen_string_literal: true

# Convert regional editors from privileges to component-user and region-user
class ConvertRegionalEditors < ActiveRecord::Migration[5.2]
  def up
    return unless Privilege.table_exists?

    @handler = Biovision::Components::BaseComponent.handler('posts')

    convert_region_managers
    convert_bloggers
    convert_reporters
    link_regions
  end

  def down
    # no rollback needed
  end

  private

  def convert_region_managers
    handler = Biovision::Components::BaseComponent.handler('regions')
    manager_privileges = {}
    Biovision::Components::RegionsComponent.privilege_names.each do |privilege_name|
      manager_privileges[privilege_name] = true
    end

    %w[chief_region_manager regional_deputy_chief_editor].each do |privilege_slug|
      privilege = Privilege.find_by(slug: privilege_slug)
      next if privilege.nil?

      privilege.user_privileges.each do |user_privilege|
        handler.user = user_privilege.user
        handler.update_privileges(user, manager_privileges)
      end
    end
  end

  def convert_bloggers
    privilege = Privilege.find_by(slug: 'blogger')
    return if privilege.nil?

    post_type = PostType['blog_post']

    privilege.users.each do |user|
      editorial_member = EditorialMember.find_or_create_by(user: user)

      EditorialMemberPostType.create(editorial_member: editorial_member, post_type: post_type)
    end
  end

  def convert_deputy_chief_editors
    type_ids = PostType.pluck(:id)

    %w[deputy_chief_editor central_deputy_editor].each do |privilege_slug|
      privilege = Privilege.find_by(slug: privilege_slug)

      next if privilege.nil?

      criteria = {
        biovision_component: @handler.component
      }

      privilege.users.each do |user|
        criteria[:user] = user
        link = BiovisionComponentUser.find_or_create_by(criteria)

        link.data['deputy_chief_editor'] = true
        link.save!

        member = EditorialMember.find_or_create_by(user: user)
        type_ids.each do |id|
          EditorialMemberPostType.create(editorial_member: member, post_type_id: id)
        end
      end
    end
  end

  def convert_reporters
    post_type = PostType['news']
    %w[reporter civic_reporter].each do |privilege_slug|
      privilege = Privilege.find_by(slug: privilege_slug)
      next if privilege.nil?

      criteria = {
        biovision_component: @handler.component
      }

      privilege.users.each do |user|
        criteria[:user] = user
        link = BiovisionComponentUser.find_or_create_by(criteria)

        link.data['editor'] = true
        link.save!

        member = EditorialMember.find_or_create_by(user: user)
        EditorialMemberPostType.create(editorial_member: member, post_type: post_type)
      end
    end
  end

  def convert_regional_editors
    mapping = {
      regional_editor: PostType['article'],
      regional_reporter: PostType['news'],
      regional_civic_reporter: PostType['news']
    }

    mapping.each do |privilege_slug, post_type|
      privilege = Privilege.find_by(slug: privilege_slug)
      next if privilege.nil?

      criteria = {
        biovision_component: @handler.component
      }

      privilege.users.each do |user|
        if privilege_slug == :regional_editor
          criteria[:user] = user
          link = BiovisionComponentUser.find_or_create_by(criteria)

          link.data['editor'] = true
          link.save!
        end

        member = EditorialMember.find_or_create_by(user: user)
        EditorialMemberPostType.create(editorial_member: member, post_type: post_type)
      end
    end
  end

  def link_regions
    UserPrivilege.where('region_id is not null').pluck(:user_id, :region_id).each do |pair|
      RegionUser.create(user_id: pair[0], region_id: pair[1])
    end
  end
end
