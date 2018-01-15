class AddResponseToAppeals171111 < ActiveRecord::Migration[5.1]
  def up
    unless column_exists?(:appeals, :appeal_type_id)
      add_reference :appeals, :appeal_type, foreign_key: { on_update: :cascade, on_delete: :nullify }
      add_column :appeals, :responder_id, :integer
      add_column :appeals, :response, :text
    end
  end

  def down
    #   No need to delete columns
  end
end
