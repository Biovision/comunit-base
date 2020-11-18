# frozen_string_literal: true

# Create record and tables for decisions component
class CreateDecisionsComponent < ActiveRecord::Migration[5.2]
  def up
    slug = Biovision::Components::DecisionsComponent.slug
    BiovisionComponent.create(slug: slug)

    create_decisions unless Decision.table_exists?
    create_decision_users unless DecisionUser.table_exists?
  end

  def down
    BiovisionComponent[Biovision::Components::DecisionsComponent.slug]&.destroy

    drop_table :decision_users if DecisionUser.table_exists?
    drop_table :decisions if Decision.table_exists?
  end

  private

  def create_decisions
    create_table :decisions, comment: 'Decisions to make' do |t|
      t.uuid :uuid, null: false
      t.references :simple_image, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.timestamps
      t.boolean :active, default: true, null: false
      t.boolean :visible, default: true, null: false
      t.date :end_date
      t.string :name, null: false
      t.text :body
      t.jsonb :answers, default: {}, null: false
      t.jsonb :data, default: {}, null: false
    end

    add_index :decisions, :uuid, unique: true
    add_index :decisions, :data, using: :gin
    add_index :decisions, :answers, using: :gin
  end

  def create_decision_users
    create_table :decision_users, comment: 'Decisions of users' do |t|
      t.references :decision, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :agent, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.inet :ip
      t.uuid :answer, index: true
      t.timestamps
      t.jsonb :data, default: {}, null: false
    end
  end
end
