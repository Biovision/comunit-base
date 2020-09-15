# frozen_string_literal: true

# Create tables for post dimensions
class CreatePostDimensions < ActiveRecord::Migration[6.0]
  def up
    create_post_dimensions unless PostDimension.table_exists?
    create_dimension_links unless PostPostDimension.table_exists?
  end

  def down
    drop_table :post_post_dimensions if PostPostDimension.table_exists?
    drop_table :post_dimensions if PostDimension.table_exists?
  end

  private

  def create_post_dimensions
    create_table :post_dimensions, comment: 'Additional dimension for posts' do |t|
      t.uuid :uuid
      t.references :site, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
      t.integer :posts_count, default: 0, null: false
      t.integer :priority, limit: 2, default: 1, null: false
      t.boolean :visible, default: true, null: false
      t.string :name, null: false
      t.string :slug, null: false
      t.jsonb :data, default: {}, null: false
    end

    add_index :post_dimensions, :uuid, unique: true
  end

  def create_dimension_links
    create_table :post_post_dimensions, comment: 'Dimension attached to post' do |t|
      t.references :post_dimension, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
    end
  end
end
