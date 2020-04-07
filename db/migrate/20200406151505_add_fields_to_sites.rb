class AddFieldsToSites < ActiveRecord::Migration[5.2]
  def change
    add_column :sites, :uuid, :uuid
    add_column :sites, :data, :jsonb
  end
end
