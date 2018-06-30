class CreatePromoItems < ActiveRecord::Migration[5.2]
  def up
    unless PromoItem.table_exists?
      create_table :promo_items do |t|
        t.timestamps
        t.references :promo_block, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.references :user, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.references :agent, foreign_key: { on_update: :cascade, on_delete: :nullify }
        t.inet :ip
        t.boolean :visible, default: true, null: false
        t.integer :item_type, limit: 2, default: 0, null: false
        t.integer :view_count, default: 0, null: false
        t.integer :click_count, default: 0, null: false
        t.string :name
        t.string :image
        t.string :url
        t.string :title
        t.string :lead
        t.text :code
        t.json :settings, default: {}, null: false
      end
    end
  end

  def down
    if PromoItem.table_exists?
      drop_table :promo_items
    end
  end
end
