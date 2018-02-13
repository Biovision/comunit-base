class AddFieldsToRegions < ActiveRecord::Migration[5.1]
  def up
    unless column_exists?(:regions, :country_id)
      add_reference :regions, :country, foreign_key: { on_update: :cascade, on_delete: :cascade }
    end
    unless column_exists?(:regions, :priority)
      add_column :regions, :priority, :integer, limit: 2, default: 1, null: false
    end
  end

  def down
    #   no need to rollback
  end
end
