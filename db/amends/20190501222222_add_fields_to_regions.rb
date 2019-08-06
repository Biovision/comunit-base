# frozen_string_literal: true

# Add posts counter and data to regions
class AddFieldsToRegions < ActiveRecord::Migration[5.2]
  def up
    return if column_exists?(:regions, :posts_count)

    add_column :regions, :posts_count, :integer, default: 0, null: false
    add_column :regions, :data, :jsonb, default: {}, null: false
  end

  def down
    # No rollback needed
  end
end
