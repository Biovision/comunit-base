class CreateAppeals < ActiveRecord::Migration[5.0]
  def up
    unless Appeal.table_exists?
      create_table :appeals do |t|
        t.timestamps
        t.references :user, foreign_key: true, on_update: :cascade, on_delete: :nullify
        t.references :agent, foreign_key: true, on_update: :cascade, on_delete: :nullify
        t.inet :ip
        t.boolean :processed, default: false, null: false
        t.boolean :deleted, default: false, null: false
        t.string :name, default: '', null: false
        t.string :subject, null: false
        t.string :email, default: '', null: false
        t.string :phone, default: '', null: false
        t.string :attachment
        t.string :uuid
        t.text :body, null: false
      end
    end
  end

  def down
    if Appeal.table_exists?
      drop_table :appeals
    end
  end
end
