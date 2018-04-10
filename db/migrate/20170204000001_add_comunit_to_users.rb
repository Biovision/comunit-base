class AddComunitToUsers < ActiveRecord::Migration[5.0]
  def up
    unless column_exists?(:users, :site_id)
      change_table :users do |t|
        t.references :site, foreign_key: { on_update: :cascade, on_delete: :nullify }
        t.integer :external_id
        t.integer :redirect_id
        t.integer :news_count, default: 0, null: false
        t.integer :posts_count, default: 0, null: false
        t.integer :entries_count, default: 0, null: false
      end
    end
  end

  def down
    if column_exists?(:users, :site_id)
      remove_column :users, :site_id
      remove_column :users, :external_id
      remove_column :users, :redirect_id
      remove_column :users, :news_count
      remove_column :users, :posts_count
      remove_column :users, :entries_count
    end
  end
end
