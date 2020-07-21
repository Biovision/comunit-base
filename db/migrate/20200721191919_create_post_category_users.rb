# frozen_string_literal: true

# Create table for linking post category and user
class CreatePostCategoryUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :post_category_users, comment: 'Allowed post category for user' do |t|
      t.references :post_category, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
    end
  end
end
