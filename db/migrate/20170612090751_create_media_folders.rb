class CreateMediaFolders < ActiveRecord::Migration[5.1]
  def up
    unless MediaFolder.table_exists?
      create_table :media_folders do |t|
        t.timestamps
        t.references :user, foreign_key: true, on_update: :cascade, on_delete: :nullify
        t.references :agent, foreign_key: true, on_update: :cascade, on_delete: :nullify
        t.inet :ip
        t.boolean :locked, default: false, null: false
        t.boolean :deleted, default: false, null: false
        t.integer :parent_id
        t.integer :flags, default: 0, null: false
        t.integer :media_files_count, default: 0, null: false
        t.string :uuid, null: false
        t.string :snapshot
        t.string :parents_cache, default: '', null: false
        t.string :name, null: false
        t.integer :children_cache, array: true, null: false, default: []
      end

      add_foreign_key :media_folders, :media_folders, column: :parent_id, on_update: :cascade, on_delete: :cascade
    end
  end

  def down
    if MediaFolder.table_exists?
      drop_table :media_folders
    end
  end
end
