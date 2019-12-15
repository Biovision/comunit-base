# frozen_string_literal: true

# Create tables for Campaigns component
class CreateCampaigns < ActiveRecord::Migration[5.2]
  def up
    create_component
    create_political_forces unless PoliticalForce.table_exists?
    create_campaigns unless Campaign.table_exists?
    create_candidates unless Candidate.table_exists?
    create_candidate_links unless CandidatePoliticalForce.table_exists?
  end

  def down
    drop_table :candidate_political_forces if CandidatePoliticalForce.table_exists?
    drop_table :candidates if Candidate.table_exists?
    drop_table :campaigns if Campaign.table_exists?
    drop_table :political_forces if PoliticalForce.table_exists?
  end

  private

  def create_component
    slug = Biovision::Components::CampaignsComponent::SLUG

    BiovisionComponent.create(slug: slug)
  end

  def create_political_forces
    create_table :political_forces, comment: 'Political forces' do |t|
      t.uuid :uuid, null: false
      t.timestamps
      t.integer :candidates_count, default: 0, null: false
      t.string :slug, null: false
      t.string :name
      t.string :image
      t.string :flare
      t.jsonb :data, default: {}, null: false
      t.jsonb :sync_state, default: {}, null: false
    end

    add_index :political_forces, :uuid, unique: true
  end

  def create_campaigns
    create_table :campaigns, comment: 'Political campaigns' do |t|
      t.uuid :uuid, null: false
      t.references :region, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
      t.boolean :active, default: true, null: false
      t.date :date
      t.integer :candidates_count, default: 0, null: false
      t.string :image
      t.string :name
      t.string :slug, null: false
      t.jsonb :sync_state, default: {}, null: false
    end

    add_index :campaigns, :uuid, unique: true
  end

  def create_candidates
    create_table :candidates, comment: 'Election candidates' do |t|
      t.uuid :uuid, null: false
      t.references :campaign, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :user, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :region, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :agent, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.inet :ip
      t.timestamps
      t.boolean :visible, default: true, null: false
      t.boolean :approved, default: false, null: false
      t.boolean :supports_impeachment, default: false, null: false
      t.date :birthday
      t.string :image
      t.string :name
      t.string :patronymic
      t.string :surname
      t.string :details_url
      t.text :lead
      t.text :about
      t.text :program
      t.jsonb :data, default: {}, null: false
      t.jsonb :sync_state, default: {}, null: false
    end

    add_index :candidates, :uuid, unique: true
  end

  def create_candidate_links
    create_table :candidate_political_forces, comment: 'Candidate in political force' do |t|
      t.references :candidate, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :political_force, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
    end
  end
end
