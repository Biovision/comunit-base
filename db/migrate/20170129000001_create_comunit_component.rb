# frozen_string_literal: true

# Create sites and add reference to users
class CreateComunitComponent < ActiveRecord::Migration[5.2]
  def up
    BiovisionComponent.create slug: Biovision::Components::ComunitComponent.slug
    create_sites unless Site.table_exists?
  end

  def down
    drop_table :sites if Site.table_exists?
    BiovisionComponent[Biovision::Components::ComunitComponent.slug]&.destroy
  end

  private

  def create_sites
    create_table :sites, comment: 'Network site' do |t|
      t.uuid :uuid
      t.timestamps
      t.references :simple_image, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.boolean :active, null: false, default: true
      t.boolean :deleted, null: false, default: false
      t.integer :users_count, null: false, default: 0
      t.integer :version, limit: 2, default: 0, null: false
      t.string :name, null: false
      t.string :host, null: false
      t.string :image
      t.string :description
      t.string :token
      t.jsonb :data, default: {}, null: false
    end

    add_index :sites, :uuid, unique: true
    add_index :sites, :data, using: :gin
  end
end
