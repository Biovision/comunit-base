# frozen_string_literal: true

# Add comunit-related fields to posts
class AddComunitToPosts < ActiveRecord::Migration[5.2]
  def up
    link_regions unless foreign_key_exists?(:posts, :regions)
  end

  def down
    # No rollback needed
  end

  private

  def link_regions
    add_foreign_key :posts, :regions, column: :region_id, on_update: :cascade, on_delete: :nullify
  end
end
