class CreateNotifications < ActiveRecord::Migration[5.0]
  def up
    unless Notification.table_exists?
      create_table :notifications do |t|
        t.timestamps
        t.references :user, foreign_key: true, null: false, on_update: :cascade, on_delete: :cascade
        t.integer :category, limit: 2, null: false
        t.integer :payload
        t.integer :repetition_count, default: 1, null: false
        t.boolean :read_by_user, default: false, null: false
      end
    end
  end

  def down
    if Notification.table_exists?
      drop_table :notifications
    end
  end
end
