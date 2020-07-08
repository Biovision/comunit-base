# frozen_string_literal: true

# Create component entry and tables for polls component
class CreatePolls < ActiveRecord::Migration[5.1]
  def up
    create_component
    create_polls unless Poll.table_exists?
    create_poll_questions unless PollQuestion.table_exists?
    create_poll_answers unless PollAnswer.table_exists?
    create_poll_votes unless PollVote.table_exists?
    create_poll_users unless PollUser.table_exists?
  end

  def down
    drop_table :poll_users if PollUser.table_exists?
    drop_table :poll_votes if PollVote.table_exists?
    drop_table :poll_answers if PollAnswer.table_exists?
    drop_table :poll_questions if PollQuestion.table_exists?
    drop_table :polls if Poll.table_exists?
  end

  private

  def create_component
    attributes = {
      slug: Biovision::Components::PollsComponent.slug,
      settings: {
        answer_limit: 10,
        question_limit: 10
      }
    }
    BiovisionComponent.create(attributes)
  end

  def create_polls
    create_table :polls, comment: 'Polls' do |t|
      t.uuid :uuid, null: false
      t.references :user, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :simple_image, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.references :agent, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.inet :ip
      t.integer :pollable_id
      t.string :pollable_type
      t.timestamps
      t.boolean :visible, default: true, null: false
      t.boolean :active, default: true, null: false
      t.boolean :show_on_homepage, default: true, null: false
      t.boolean :anonymous_votes, default: true, null: false
      t.boolean :open_results, default: true, null: false
      t.boolean :exclusive, default: false, null: false
      t.boolean :allow_comments, default: true, null: false
      t.date :end_date
      t.integer :poll_questions_count, default: 0, null: false
      t.integer :comments_count, default: 0, null: false
      t.string :name
      t.string :description
      t.jsonb :data, default: {}, null: false
    end

    add_index :polls, :uuid, unique: true
    add_index :polls, :data, using: :gin
  end

  def create_poll_questions
    create_table :poll_questions, comment: 'Poll questions' do |t|
      t.uuid :uuid, null: false
      t.references :poll, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :simple_image, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.integer :priority, limit: 2, default: 1, null: false
      t.timestamps
      t.integer :poll_answers_count, default: 0, null: false
      t.boolean :multiple_choice, default: false, null: false
      t.string :text, null: false
      t.string :comment
      t.jsonb :data, default: {}, null: false
    end

    add_index :poll_questions, :uuid, unique: true
    add_index :poll_questions, :data, using: :gin
  end

  def create_poll_answers
    create_table :poll_answers, comment: 'Answers for poll questions' do |t|
      t.uuid :uuid, null: false
      t.references :poll_question, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :simple_image, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.integer :priority, limit: 2, default: 1, null: false
      t.timestamps
      t.integer :poll_votes_count, default: 0, null: false
      t.string :text, null: false
      t.jsonb :data, default: {}, null: false
    end

    add_index :poll_answers, :uuid, unique: true
    add_index :poll_answers, :data, using: :gin
  end

  def create_poll_votes
    create_table :poll_votes, comment: 'Votes for poll answers' do |t|
      t.uuid :uuid, null: false
      t.references :poll_answer, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :user, foreign_key: true, on_update: :cascade, on_delete: :cascade
      t.references :agent, foreign_key: true, on_update: :cascade, on_delete: :nullify
      t.inet :ip
      t.timestamps
      t.string :slug
      t.jsonb :data, default: {}, null: false
    end

    add_index :poll_votes, :uuid, unique: true
  end

  def create_poll_users
    create_table :poll_users, comment: 'Allowed users in exclusive polls' do |t|
      t.timestamps
      t.references :poll, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
    end
  end
end
