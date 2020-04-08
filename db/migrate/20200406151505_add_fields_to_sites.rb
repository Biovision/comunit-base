# frozen_string_literal: true

# Add UUID and data fields to sites table
class AddFieldsToSites < ActiveRecord::Migration[5.2]
  def up
    return if column_exists? :sites, :uuid

    add_column :sites, :uuid, :uuid
    add_column :sites, :data, :jsonb, default: {}, null: false

    add_index :sites, :uuid, unique: true
    add_index :sites, :data, using: :gin
  end

  def down
    # no rollback needed
  end
end
