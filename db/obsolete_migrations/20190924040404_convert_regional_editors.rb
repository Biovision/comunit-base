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

    %w[chief_region_manager regional_deputy_chief_editor].each do |privilege_slug|
      privilege = Privilege.find_by(slug: privilege_slug)
      next if privilege.nil?

      privilege.user_privileges.each do |user_privilege|
        handler.user = user_privilege.user
        Biovision::Components::RegionsComponent.privilege_names.each do |slug|
          handler.privilege_handler.add_privilege(slug)
        end
      end
    end
  end

  def convert_bloggers
    privilege = Privilege.find_by(slug: 'blogger')
    return if privilege.nil?

    post_type = PostType['blog_post']

    privilege.users.each do |user|
      @handler.user = user
      @handler.allow_post_type(post_type)
    end
  end

  def convert_deputy_chief_editors
    %w[deputy_chief_editor central_deputy_editor].each do |privilege_slug|
      privilege = Privilege.find_by(slug: privilege_slug)

      next if privilege.nil?

      privilege.users.each do |user|
        @handler.user = user
        @handler.privilege_handler.add_privilege('deputy_chief_editor')
      end
    end
  end

  def convert_reporters
    post_type = PostType['news']
    %w[reporter civic_reporter].each do |privilege_slug|
      privilege = Privilege.find_by(slug: privilege_slug)
      next if privilege.nil?

      privilege.users.each do |user|
        @handler.user = user
        @handler.allow_post_type(post_type)
        post_type.post_categories.each do |post_category|
          @handler.allow_post_category(post_category)
        end
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

      privilege.users.each do |user|
        @handler.user = user
        @handler.privilege_handler.add_privilege(privilege_slug)
        @handler.add_post_type(post_type)
        post_type.post_categories.each do |post_category|
          @handler.add_post_category(post_category)
        end
      end
    end
  end

  def link_regions
    UserPrivilege.where('region_id is not null').pluck(:user_id, :region_id).each do |pair|
      RegionUser.create(user_id: pair[0], region_id: pair[1])
    end
  end
end
