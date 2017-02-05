class CreateTokens < ActiveRecord::Migration[5.0]
  def up
    unless Token.table_exists?
      create_table :tokens do |t|
        t.timestamps
        t.datetime :last_used
        t.references :user, foreign_key: true, null: false, on_update: :cascade, on_delete: :cascade
        t.references :agent, foreign_key: true, on_update: :cascade, on_delete: :nullify
        t.inet :ip
        t.boolean :active, default: true, null: false
        t.string :token, null: false
      end
    end
  end

  def down
    if Token.table_exists?
      drop_table :tokens
    end
  end
end
