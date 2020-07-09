class CreateAppeals < ActiveRecord::Migration[5.0]
  def up
    unless Appeal.table_exists?
      create_table :appeals do |t|
        t.timestamps
        t.references :appeal_type, foreign_key: { on_update: :cascade, on_delete: :nullify }
        t.references :user, foreign_key: { on_update: :cascade, on_delete: :nullify }
        t.references :agent, foreign_key: { on_update: :cascade, on_delete: :nullify }
        t.inet :ip
        t.integer :responder_id
        t.boolean :processed, default: false, null: false
        t.boolean :deleted, default: false, null: false
        t.string :name, default: '', null: false
        t.string :subject, null: false
        t.string :email, default: '', null: false
        t.string :phone, default: '', null: false
        t.string :attachment
        t.string :uuid
        t.text :body, null: false
        t.text :response
      end

      add_foreign_key :appeals, :users, column: :responder_id, on_update: :cascade, on_delete: :nullify
    end
  end

  def down
    if Appeal.table_exists?
      drop_table :appeals
    end
  end
end
