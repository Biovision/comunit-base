# frozen_string_literal: true

# Convert themes to post category groups
class ConvertThemes < ActiveRecord::Migration[5.2]
  def up
    return unless Theme.table_exists?

    Theme.order('id asc').each { |theme| convert_theme(theme) }
  end

  def down
    # No rollback needed
  end

  private

  # @param [Theme] theme
  def convert_theme(theme)
    post_group = PostGroup.find_by(slug: theme.slug) || PostGroup.create(slug: theme.slug, name: theme.name)
    theme.post_categories.pluck(:id).each do |id|
      PostGroupCategory.create(post_group_id: post_group.id, post_category_id: id)
    end
  end
end
