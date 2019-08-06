class CreateTeams < ActiveRecord::Migration[5.0]
  def up
    unless Team.table_exists?
      create_table :teams do |t|
        t.timestamps
        t.boolean :visible, default: true, null: false
        t.integer :priority, limit: 2, default: 1, null: false
        t.integer :team_privileges_count, default: 0, null: false
        t.string :slug, index: true, null: false
        t.string :name, null: false
        t.string :description, default: '', null: false
        t.string :image
      end
    end
  end

  def down
    if Team.table_exists?
      drop_table :teams
    end
  end
end
