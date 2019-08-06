# frozen_string_literal: true

# Tables for themes for main page
class CreateThemes < ActiveRecord::Migration[5.2]
  def up
    create_themes unless Theme.table_exists?
    create_theme_post_categories unless ThemePostCategory.table_exists?
  end

  def down
    drop_table :theme_post_categories if ThemePostCategory.table_exists?
    drop_table :themes if Theme.table_exists?
  end

  private

  def create_themes
    create_table :themes, comment: 'Theme of posts' do |t|
      t.timestamps
      t.boolean :locked, default: false, null: false
      t.integer :post_categories_count, limit: 2, default: 0, null: false
      t.string :name, null: false
      t.string :slug, null: false
    end

    seed_themes
  end

  def create_theme_post_categories
    create_table :theme_post_categories, comment: 'Post category in theme' do |t|
      t.references :theme, foreign_key: { on_update: :cascade, on_delete: :cascade }, null: false
      t.references :post_category, foreign_key: { on_update: :cascade, on_delete: :cascade }, null: false
    end
  end

  def seed_themes
    Theme.create(slug: 'main-news', name: 'Главные новости')
    Theme.create(slug: 'video', name: 'Видео')
  end
end
