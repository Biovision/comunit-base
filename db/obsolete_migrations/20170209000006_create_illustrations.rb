class CreateIllustrations < ActiveRecord::Migration[5.0]
  def up
    unless Illustration.table_exists?
      create_table :illustrations do |t|
        t.timestamps
        t.references :user, foreign_key: { on_update: :cascade, on_delete: :nullify }
        t.string :name
        t.string :image
      end
    end
  end

  def down
    if Illustration.table_exists?
      drop_table :illustrations
    end
  end
end
