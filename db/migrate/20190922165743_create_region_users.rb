# frozen_string_literal: true

# Create table for user-region link
class CreateRegionUsers < ActiveRecord::Migration[5.2]
  def change
    create_region_users unless RegionUser.table_exists?
  end

  def down
    drop_table :region_users if RegionUser.table_exists?
  end

  private

  def create_region_users
    create_table :region_users, comment: 'Link between region and user' do |t|
      t.references :region, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
    end
  end
end
