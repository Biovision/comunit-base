class CreateEntries < ActiveRecord::Migration[5.0]
  def up
    unless Entry.table_exists?
      create_table :entries do |t|
        t.timestamps
        t.integer :external_id
        t.references :user, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.references :agent, foreign_key: { on_update: :cascade, on_delete: :nullify }
        t.inet :ip
        t.integer :community_id
        t.boolean :deleted, default: false, null: false
        t.boolean :show_name, default: true, null: false
        t.integer :privacy, limit: 2, default: 0, null: false
        t.integer :comments_count, default: 0, null: false
        t.integer :view_count, default: 0, null: false
        t.integer :rating, default: 0, null: false
        t.integer :upvote_count, default: 0, null: false
        t.integer :downvote_count, default: 0, null: false
        t.integer :vote_result, default: 0, null: false
        t.datetime :publication_time
        t.string :title
        t.string :slug
        t.string :image
        t.string :image_name
        t.string :image_author_name
        t.string :image_author_link
        t.string :source
        t.string :source_link
        t.text :lead
        t.text :body, null: false
      end

      execute "create index entries_created_month_idx on entries using btree (date_trunc('month', created_at));"
      execute "create index entries_published_month_idx on entries using btree (date_trunc('month', publication_time));"

      Entry.__elasticsearch__.create_index!
    end
  end

  def down
    if Entry.table_exists?
      drop_table :entries
    end
  end
end
