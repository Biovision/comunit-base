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
    Region.connection.execute "select setval('regions_id_seq', (select max(id) from regions));"

    add_reference :countries, :simple_image, foreign_key: { on_update: :cascade, on_delete: :nullify }
    add_column :countries, :uuid, :uuid
    add_column :countries, :data, :jsonb, default: {}, null: false
    add_index :countries, :uuid, unique: true
    add_index :countries, :data, using: :gin
    Country.connection.execute "select setval('regions_id_seq', (select max(id) from countries));"
  end

  def down
    # No rollback needed
  end
end
