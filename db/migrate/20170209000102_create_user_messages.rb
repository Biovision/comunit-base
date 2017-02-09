class CreateUserMessages < ActiveRecord::Migration[5.0]
  def up
    unless UserMessage.table_exists?
      create_table :user_messages do |t|
        t.timestamps
        t.references :agent, foreign_key: true, on_update: :cascade, on_delete: :cascade
        t.inet :ip
        t.integer :sender_id
        t.integer :receiver_id
        t.boolean :read_by_receiver, default: false, null: false
        t.boolean :deleted_by_sender, default: false, null: false
        t.boolean :deleted_by_receiver, default: false, null: false
        t.text :body, null: false
      end

      add_foreign_key :user_messages, :users, column: :sender_id, on_update: :cascade, on_delete: :cascade
      add_foreign_key :user_messages, :users, column: :receiver_id, on_update: :cascade, on_delete: :cascade
    end
  end

  def down
    if UserMessage.table_exists?
      drop_table :user_messages
    end
  end
end
