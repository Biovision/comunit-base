class CreateAppealTypes < ActiveRecord::Migration[5.1]
  def up
    unless AppealType.table_exists?
      create_table :appeal_types do |t|
        t.timestamps
        t.string :name, null: false
        t.boolean :visible, default: true, null: false
        t.integer :priority, limit: 2, default: 1, null: false
        t.integer :appeals_count, default: 0, null: false
      end
    end
  end

  def down
    if AppealType.table_exists?
      drop_table :appeal_types
    end
  end
end
