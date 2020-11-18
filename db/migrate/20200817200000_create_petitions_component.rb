# frozen_string_literal: true

# Create tables for petitions component
class CreatePetitionsComponent < ActiveRecord::Migration[6.0]
  def up
    BiovisionComponent.create(slug: Biovision::Components::PetitionsComponent.slug)
    create_petitions unless Petition.table_exists?
    create_petition_signs unless PetitionSign.table_exists?
  end

  def down
    BiovisionComponent[Biovision::Components::PetitionsComponent]&.destroy
    drop_table :petition_signs if PetitionSign.table_exists?
    drop_table :petitions if Petition.table_exists?
  end

  private

  def create_petitions
    create_table :petitions, comment: 'Petitions' do |t|
      t.uuid :uuid, null: false
      t.references :user, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.references :agent, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.inet :ip
      t.integer :petition_signs_count, default: 0, null: false
      t.timestamps
      t.boolean :visible, default: true, null: false
      t.boolean :active, default: true, null: false
      t.string :title
      t.text :description
      t.jsonb :data, default: {}, null: false
    end

    add_index :petitions, :uuid, unique: true
    add_index :petitions, :data, using: :gin
  end

  def create_petition_signs
    create_table :petition_signs, comment: 'Petition signs' do |t|
      t.uuid :uuid, null: false
      t.references :petition, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      # t.references :region, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.references :user, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.references :agent, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.inet :ip
      t.boolean :visible, default: true, null: false
      t.timestamps
      t.string :surname
      t.string :name
      t.string :email, index: true
      t.jsonb :data, default: {}, null: false
    end

    add_index :petition_signs, :uuid, unique: true
    add_index :petition_signs, :data, using: :gin
  end
end
