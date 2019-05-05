# frozen_string_literal: true

# Create sites and add reference to users
class CreateSites < ActiveRecord::Migration[5.2]
  def up
    create_sites unless Site.table_exists?
  end

  def down
    drop_table :sites if Site.table_exists?
  end

  private

  def create_sites
    create_table :sites, comment: 'Network site' do |t|
      t.timestamps
      t.boolean :active, null: false, default: true
      t.boolean :deleted, null: false, default: false
      t.integer :users_count, null: false, default: 0
      t.string :name, null: false
      t.string :host, null: false
      t.string :image
      t.string :description
    end
  end
end
