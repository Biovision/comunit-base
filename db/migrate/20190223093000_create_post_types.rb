# frozen_string_literal: true

# Tables for post type, category and tag
class CreatePostTypes < ActiveRecord::Migration[5.2]
  def up
    create_post_types unless PostType.table_exists?
    create_post_categories unless PostCategory.table_exists?
    create_post_tags unless PostTag.table_exists?
  end

  def down
    drop_table :post_tags if PostTag.table_exists?
    drop_table :post_categories if PostCategory.table_exists?
    drop_table :post_types if PostType.table_exists?
  end

  private

  def create_post_types
    create_table :post_types, comment: 'Post type' do |t|
      t.timestamps
      t.boolean :active, default: true, null: false
      t.integer :posts_count, default: 0, null: false
      t.integer :category_depth, limit: 2, default: 1, null: false
      t.string :name, null: false
      t.string :slug, null: false
      t.string :default_category_name
    end

    add_index :post_types, :slug, unique: true
    add_index :post_types, :name, unique: true

    create_default_types
  end

  def create_post_categories
    create_table :post_categories, comment: 'Post category' do |t|
      t.references :post_type, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.integer :parent_id
      t.integer :priority, limit: 2, default: 1, null: false
      t.integer :posts_count, default: 0, null: false
      t.timestamps
      t.boolean :locked, default: false, null: false
      t.boolean :visible, default: true, null: false
      t.boolean :deleted, default: false, null: false
      t.string :name, null: false
      t.string :slug, null: false
      t.string :long_slug, null: false
      t.string :nav_text
      t.string :meta_description
      t.string :parents_cache, default: '', null: false
      t.integer :children_cache, default: [], array: true, null: false
      t.jsonb :data, default: {}, null: false
    end

    add_foreign_key :post_categories, :post_categories, column: :parent_id, on_update: :cascade, on_delete: :cascade
  end

  def create_post_tags
    create_table :post_tags, comment: 'Post tag' do |t|
      t.references :post_type, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.integer :posts_count, default: 0, null: false
      t.timestamps
      t.string :name
      t.string :slug, index: true
    end
  end

  def create_default_types
    PostType.create(slug: 'blog_post', name: 'Запись в блоге', default_category_name: 'Блог')
    PostType.create(slug: 'article', name: 'Статья', default_category_name: 'Статьи')
    PostType.create(slug: 'news', name: 'Новость', default_category_name: 'Новости')
  end
end