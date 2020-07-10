# frozen_string_literal: true

# Create table for countries and regions
class CreateRegionsComponent < ActiveRecord::Migration[5.2]
  def up
    BiovisionComponent.create slug: Biovision::Components::RegionsComponent.slug
    create_countries unless Country.table_exists?
    create_regions unless Region.table_exists?
  end

  def down
    drop_table :regions if Region.table_exists?
    drop_table :countries if Country.table_exists?
    BiovisionComponent[Biovision::Components::RegionsComponent]&.destroy
  end

  private

  def create_countries
    create_table :countries, comment: 'Country' do |t|
      t.uuid :uuid
      t.references :simple_image, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.integer :priority, limit: 2, default: 1, null: false
      t.boolean :visible, default: true, null: false
      t.integer :regions_count, default: 0, null: false
      t.timestamps
      t.string :name, null: false
      t.string :short_name
      t.string :locative
      t.string :slug
      t.jsonb :data, default: {}, null: false
    end

    Country.create(
      name: 'Российская Федерация',
      short_name: 'Россия',
      locative: 'в России',
      slug: 'russia'
    )
  end

  def create_regions
    create_table :regions, comment: 'Region' do |t|
      t.uuid
      t.timestamps
      t.references :country, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.integer :parent_id
      t.references :simple_image, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.integer :priority, limit: 2, default: 1, null: false
      t.integer :users_count, default: 0, null: false
      t.integer :posts_count, default: 0, null: false
      t.boolean :visible, default: true, null: false
      t.float :latitude
      t.float :longitude
      t.string :slug, null: false
      t.string :long_slug, null: false, index: true
      t.string :name, null: false
      t.string :short_name
      t.string :locative
      t.string :header_image
      t.text :map_geometry
      t.text :svg_geometry
      t.string :parents_cache, default: '', null: false
      t.integer :children_cache, array: true, default: [], null: false
      t.jsonb :data, default: {}, null: false
    end

    add_foreign_key :regions, :regions, column: :parent_id, on_update: :cascade, on_delete: :cascade
    add_index :regions, :uuid, unique: true
    add_index :regions, :data, using: :gin
  end
end
