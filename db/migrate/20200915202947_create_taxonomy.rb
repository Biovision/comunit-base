# frozen_string_literal: true

# Create tables for taxonomy
class CreateTaxonomy < ActiveRecord::Migration[6.0]
  def up
    create_taxons unless Taxon.table_exists?
    create_dimension_links unless PostTaxon.table_exists?
  end

  def down
    drop_table :post_taxons if PostTaxon.table_exists?
    drop_table :taxons if Taxon.table_exists?
  end

  private

  def create_taxons
    create_table :taxons, comment: 'Taxons for posts' do |t|
      t.uuid :uuid, null: false
      t.references :site, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
      t.integer :posts_count, default: 0, null: false
      t.integer :priority, limit: 2, default: 1, null: false
      t.boolean :visible, default: true, null: false
      t.string :name, null: false
      t.string :slug, null: false
      t.jsonb :data, default: {}, null: false
    end

    add_index :taxons, :uuid, unique: true
  end

  def create_dimension_links
    create_table :post_taxons, comment: 'Taxon attached to post' do |t|
      t.references :taxon, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
    end
  end
end
