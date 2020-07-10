# frozen_string_literal: true

# Add fields to sites and regions to make uniform DB structure
class AmendSitesAndRegions < ActiveRecord::Migration[6.0]
  def up
    BiovisionComponent.create slug: Biovision::Components::ComunitComponent.slug
    add_reference :sites, :simple_image, foreign_key: { on_update: :cascade, on_delete: :nullify }
    add_column :sites, :version, :integer, limit: 2, default: 0, null: false
    add_column :sites, :token, :string

    add_reference :regions, :simple_image, foreign_key: { on_update: :cascade, on_delete: :nullify }
    add_column :regions, :uuid, :uuid
    add_index :regions, :uuid, unique: true
    add_index :regions, :data, using: :gin
  end

  def down
    # No rollback needed
  end
end
