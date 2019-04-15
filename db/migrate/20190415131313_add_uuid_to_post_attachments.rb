# frozen_string_literal: true

# Add UUID field to post attachments
class AddUuidToPostAttachments < ActiveRecord::Migration[5.2]
  def up
    return if column_exists? :post_attachments, :uuid

    add_column :post_attachments, :uuid, :uuid

    PostAttachment.order('id asc').each(&:save)
  end

  def down
    # No rollback needed
  end
end
