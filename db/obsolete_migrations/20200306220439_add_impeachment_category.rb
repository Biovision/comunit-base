# frozen_string_literal: true

# Add impeachment category to articles
class AddImpeachmentCategory < ActiveRecord::Migration[5.2]
  def up
    PostType['article'].post_categories.create(slug: 'impeachment', name: 'Импичмент')
  end

  def down
    # no rollback needed
  end
end
