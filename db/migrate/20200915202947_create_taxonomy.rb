# frozen_string_literal: true

# Create tables for taxonomy
class CreateTaxonomy < ActiveRecord::Migration[6.0]
  def up
    create_taxon_types unless TaxonType.table_exists?
    create_taxons unless Taxon.table_exists?
    create_taxon_users unless TaxonUser.table_exists?
    create_taxon_links unless PostTaxon.table_exists?
  end

  def down
    drop_table :post_taxons if PostTaxon.table_exists?
    drop_table :taxon_users if TaxonUser.table_exists?
    drop_table :taxons if Taxon.table_exists?
    drop_table :taxon_types if TaxonType.table_exists?
  end

  private

  def create_taxon_types
    create_table :taxon_types, comment: 'Taxon types' do |t|
      t.uuid :uuid, null: false
      t.references :site, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
      t.string :name, null: false
      t.string :slug, null: false
      t.jsonb :data, default: {}, null: false
    end

    add_index :taxon_types, :uuid, unique: true
    add_index :taxon_types, %i[slug site_id]
    add_index :taxon_types, :data, using: :gin
  end

  def create_taxons
    create_table :taxons, comment: 'Taxa for posts' do |t|
      t.uuid :uuid, null: false
      t.references :site, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :taxon_type, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.integer :parent_id
      t.timestamps
      t.integer :posts_count, default: 0, null: false
      t.integer :priority, limit: 2, default: 1, null: false
      t.boolean :visible, default: true, null: false
      t.string :name, null: false
      t.string :nav_text
      t.string :slug, null: false
      t.string :parents_cache, default: '', null: false
      t.integer :children_cache, array: true, default: [], null: false
      t.jsonb :data, default: {}, null: false
    end

    add_index :taxons, :uuid, unique: true
    add_index :taxons, :data, using: :gin
  end

  def create_taxon_users
    create_table :taxon_users, comment: 'Taxons available to users' do |t|
      t.references :taxon, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
    end
  end

  def create_taxon_links
    create_table :post_taxons, comment: 'Taxon attached to post' do |t|
      t.references :taxon, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
    end
  end
end
