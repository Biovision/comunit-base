# frozen_string_literal: true

# Create tables for taxonomy
class CreateTaxonomyComponent < ActiveRecord::Migration[6.0]
  def up
    BiovisionComponent.create(slug: Biovision::Components::TaxonomyComponent.slug)
    create_taxon_types unless TaxonType.table_exists?
    create_taxon_type_component unless TaxonTypeBiovisionComponent.table_exists?
    create_taxa unless Taxon.table_exists?
    create_taxon_users unless TaxonUser.table_exists?
  end

  def down
    [TaxonUser, Taxon, TaxonTypeBiovisionComponent, TaxonType].each do |model|
      drop_table model.table_name if model.table_exists?
    end

    BiovisionComponent[Biovision::Components::TaxonomyComponent.slug]&.destroy
  end

  private

  def create_taxon_types
    create_table :taxon_types, comment: 'Taxon types' do |t|
      t.uuid :uuid, null: false
      t.references :simple_image, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.timestamps
      t.boolean :active, default: true, null: false
      t.string :name, null: false
      t.string :slug, null: false, index: true
      t.jsonb :data, default: {}, null: false
    end

    add_index :taxon_types, :uuid, unique: true
    add_index :taxon_types, :data, using: :gin
  end

  def create_taxa
    create_table :taxa, comment: 'Taxa for posts' do |t|
      t.uuid :uuid, null: false
      t.references :simple_image, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.references :taxon_type, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.integer :parent_id
      t.timestamps
      t.integer :object_count, default: 0, null: false
      t.integer :priority, limit: 2, default: 1, null: false
      t.boolean :visible, default: true, null: false
      t.string :name, null: false
      t.string :nav_text
      t.string :slug, null: false
      t.string :parents_cache, default: '', null: false
      t.integer :children_cache, array: true, default: [], null: false
      t.jsonb :data, default: {}, null: false
    end

    add_index :taxa, :uuid, unique: true
    add_index :taxa, :data, using: :gin
  end

  def create_taxon_users
    create_table :taxon_users, comment: 'Taxa available to users' do |t|
      t.references :taxon, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
    end
  end

  def create_taxon_type_component
    create_table :taxon_type_biovision_components, comment: 'Taxon types for component' do |t|
      t.references :taxon_type, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :biovision_component, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
    end
  end
end
