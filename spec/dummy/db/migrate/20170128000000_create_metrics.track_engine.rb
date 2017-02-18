# This migration comes from track_engine (originally 20170128000001)
class CreateMetrics < ActiveRecord::Migration[5.0]
  def up
    unless Metric.table_exists?
      create_table :metrics do |t|
        t.timestamps
        t.boolean :incremental, null: false, default: false
        t.boolean :start_with_zero, null: false, default: false
        t.boolean :show_on_dashboard, null: false, default: true
        t.integer :default_period, limit: 2, null: false, default: 7
        t.integer :value, null: false, default: 0
        t.integer :previous_value, null: false, default: 0
        t.string :name, null: false
        t.string :description, null: false, default: ''
      end
    end
  end

  def down
    if Metric.table_exists?
      drop_table :metrics
    end
  end
end
