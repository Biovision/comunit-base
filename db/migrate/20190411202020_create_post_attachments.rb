# frozen_string_literal: true

# Create table for post attachment
class CreatePostAttachments < ActiveRecord::Migration[5.2]
  def up
    create_table :post_attachments, comment: 'Attachment for post' do |t|
      t.references :post, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
      t.string :name
      t.string :file
    end
  end

  def down
    drop_table :post_attachments if PostAttachment.table_exists?
  end
end
