# frozen_string_literal: true

# Add missing fields to tables for posts component
class AmendPostsComponent < ActiveRecord::Migration[6.0]
  def up
    add_column :post_categories, :uuid, :uuid
    add_reference :post_categories, :site, foreign_key: { on_update: :cascade, on_delete: :cascade }
    add_index :post_categories, :uuid, unique: true
    add_index :post_categories, :data, using: :gin
    site = Site.find_by(uuid: ENV['SITE_ID'])
    PostCategory.order('id asc').each do |post_category|
      post_category.site = site
      post_category.save!
    end

    add_reference :posts, :simple_image, foreign_key: { on_update: :cascade, on_delete: :nullify }

    add_column :post_links, :uuid, :uuid
    add_column :post_links, :data, :jsonb, default: {}, null: false
    add_index :post_links, :uuid, unique: true
    add_index :post_links, :data, using: :gin
    PostLink.order('id asc').each(&:save!)

    add_reference :post_images, :simple_image, foreign_key: { on_update: :cascade, on_delete: :nullify }
    add_column :post_images, :data, :jsonb, default: {}, null: false
    add_index :post_images, :data, using: :gin

    add_column :post_references, :uuid, :uuid
    add_column :post_references, :data, :jsonb, default: {}, null: false
    add_index :post_references, :uuid, unique: true
    add_index :post_references, :data, using: :gin
    PostReference.order('id asc').each(&:save!)

    add_column :post_notes, :uuid, :uuid
    add_column :post_notes, :data, :jsonb, default: {}, null: false
    add_index :post_notes, :uuid, unique: true
    add_index :post_notes, :data, using: :gin
    PostNote.order('id asc').each(&:save!)

    add_column :post_attachments, :data, :jsonb, default: {}, null: false
    add_index :post_attachments, :data, using: :gin
  end

  def down
    # No rollback
  end
end
