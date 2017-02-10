class CreateUserLinks < ActiveRecord::Migration[5.0]
  def up
    unless UserLink.table_exists?
      create_table :user_links do |t|
        t.timestamps
        t.references :agent, foreign_key: true, on_update: :cascade, on_delete: :nullify
        t.inet :ip
        t.integer :follower_id, null: false
        t.integer :followee_id, null: false
        t.boolean :visible, default: true, null: false
      end

      add_foreign_key :user_links, :users, column: :follower_id, on_update: :cascade, on_delete: :cascade
      add_foreign_key :user_links, :users, column: :followee_id, on_update: :cascade, on_delete: :cascade
    end
  end

  def down
    if UserLink.table_exists?
      drop_table :user_links
    end
  end
end
