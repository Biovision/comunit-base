# frozen_string_literal: true

# Create component and tables for deeds
class CreateDeedsComponent < ActiveRecord::Migration[5.2]
  def up
    BiovisionComponent.create(slug: Biovision::Components::DeedsComponent.slug)
    create_deed_categories unless DeedCategory.table_exists?
    create_deeds unless Deed.table_exists?
    create_deed_category_links unless DeedDeedCategory.table_exists?
    create_deed_images unless DeedImage.table_exists?
  end
  
  def down
    drop_table :deed_images if DeedImage.table_exists?
    drop_table :deed_deed_categories if DeedDeedCategory.table_exists?
    drop_table :deeds if Deed.table_exists?
    drop_table :deed_categories if DeedCategory.table_exists?
    BiovisionComponent[Biovision::Components::DeedsComponent.slug]&.destroy
  end
  
  private
  
  def create_deed_categories
    create_table :deed_categories, comment: 'Deed categories' do |t|
      t.uuid :uuid, null: false
      t.integer :parent_id
      t.integer :priority, limit: 2, default: 1, null: false
      t.timestamps
      t.boolean :visible, default: true, null: false
      t.integer :deeds_count, default: 0, null: false
      t.string :name
      t.string :parents_cache, default: '', null: false
      t.integer :children_cache, array: true, default: [], null: false
      t.jsonb :data, default: {}, null: false
    end

    add_foreign_key :deed_categories, :deed_categories, column: :parent_id, on_update: :cascade, on_delete: :cascade
    add_index :deed_categories, :uuid, unique: true
    add_index :deed_categories, %i[name parent_id]
    add_index :deed_categories, :data, using: :gin
  end

  def create_deeds
    create_table :deeds, comment: 'Deeds' do |t|
      t.uuid :uuid, null: false
      t.references :user, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :region, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.references :agent, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.inet :ip
      t.timestamps
      t.integer :view_count, default: 0, null: false
      t.boolean :offer, default: false, null: false
      t.boolean :done, default: false, null: false
      t.boolean :visible, default: true, null: false
      t.integer :comments_count, default: 0, null: false
      t.string :image
      t.string :title
      t.text :description
      t.jsonb :data, default: {}, null: false
    end

    add_index :deeds, :uuid, unique: true
    add_index :deeds, :data, using: :gin
  end

  def create_deed_category_links
    create_table :deed_deed_categories, comment: 'Links between deeds and categories' do |t|
      t.references :deed, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :deed_category, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
    end
  end

  def create_deed_images
    create_table :deed_images, comment: 'Deed images' do |t|
      t.uuid :uuid, null: false
      t.references :deed, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
      t.integer :priority, limit: 2, default: 1, null: false
      t.string :image
      t.string :caption
      t.text :description
      t.jsonb :data, default: {}, null: false
    end

    add_index :deed_images, :uuid, unique: true
    add_index :deed_images, :data, using: :gin
  end
end
