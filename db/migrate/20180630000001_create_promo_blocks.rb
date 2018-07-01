class CreatePromoBlocks < ActiveRecord::Migration[5.2]
  def up
    unless PromoBlock.table_exists?
      create_table :promo_blocks do |t|
        t.timestamps
        t.references :language, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.boolean :visible, default: true, null: false
        t.integer :promo_items_count, default: 0, null: false
        t.string :slug, null: false
        t.string :name
        t.string :description
      end

      create_privileges
    end
  end

  def down
    if PromoBlock.table_exists?
      drop_table :promo_blocks
    end
  end

  private

  def create_privileges
    Privilege.create(slug: 'promo_manager', name: 'Управляющий рекламой')
  end
end
