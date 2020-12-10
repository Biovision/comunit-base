# frozen_string_literal: true

# Create component for trade unions
class CreateTradeUnions < ActiveRecord::Migration[6.0]
  def up
    create_component
    create_trade_unions unless TradeUnion.table_exists?
    create_trade_union_taxa unless TradeUnionTaxon.table_exists?
    create_trade_union_users unless TradeUnionUser.table_exists?
    create_trade_union_documents unless TradeUnionDocument.table_exists?
  end

  def down
    [
      TradeUnionDocument, TradeUnionUser, TradeUnionTaxon, TradeUnion
    ].each do |model|
      drop_table model.table_name if model.table_exists?
    end

    BiovisionComponent[Biovision::Components::TradeUnionsComponent.slug]&.destroy
  end

  private

  def create_component
    slug = Biovision::Components::TradeUnionsComponent.slug
    BiovisionComponent.create(slug: slug)
  end

  def create_trade_unions
    create_table :trade_unions, comment: 'Trade unions' do |t|
      t.uuid :uuid, null: false
      t.references :simple_image, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.timestamps
      t.integer :user_count, default: 0, null: false
      t.string :name
      t.string :slug
      t.text :lead
      t.text :description
      t.jsonb :data, default: {}, null: false
      t.jsonb :extra, default: {}, null: false
    end

    add_index :trade_unions, :uuid, unique: true
    add_index :trade_unions, :data, using: :gin
    add_index :trade_unions, :extra, using: :gin
  end

  def create_trade_union_taxa
    create_table :trade_union_taxa, comment: 'Taxon in trade union' do |t|
      t.references :trade_union, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :taxon, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
    end
  end

  def create_trade_union_users
    create_table :trade_union_users, comment: 'User in trade union' do |t|
      t.references :trade_union, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
      t.jsonb :data, default: {}, null: false
    end

    add_index :trade_union_users, :data, using: :gin
  end

  def create_trade_union_documents
    create_table :trade_union_documents, comment: 'Document in trade union' do |t|
      t.uuid :uuid, null: false
      t.references :trade_union, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.integer :priority, limit: 2, default: 1, null: false
      t.timestamps
      t.string :name
      t.string :attachment
      t.jsonb :data, default: {}, null: false
    end

    add_index :trade_union_documents, :uuid, unique: true
    add_index :trade_union_documents, :data, using: :gin
  end
end
