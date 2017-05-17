class CreatePosts < ActiveRecord::Migration[5.0]
  def up
    unless Post.table_exists?
      create_table :posts do |t|
        t.timestamps
        t.integer :external_id
        t.references :user, foreign_key: true, on_update: :cascade, on_delete: :nullify
        t.references :post_category, foreign_key: true, on_update: :cascade, on_delete: :nullify
        t.references :agent, foreign_key: true, on_update: :cascade, on_delete: :nullify
        t.inet :ip
        t.boolean :visible, default: true, null: false
        t.boolean :locked, default: false, null: false
        t.boolean :deleted, default: false, null: false
        t.boolean :approved, default: true, null: false
        t.boolean :show_name, default: true, null: false
        t.boolean :allow_comments, default: true, null: false
        t.boolean :main_post, default: false, null: false
        t.integer :entry_id
        t.integer :author_id
        t.integer :comments_count, default: 0, null: false
        t.integer :view_count, default: 0, null: false
        t.integer :upvote_count, default: 0, null: false
        t.integer :downvote_count, default: 0, null: false
        t.integer :vote_result, default: 0, null: false
        t.datetime :publication_time
        t.string :title, null: false
        t.string :slug, null: false
        t.string :image
        t.string :image_name
        t.string :image_author_name
        t.string :image_author_link
        t.string :source
        t.string :source_link
        t.text :lead
        t.text :body, null: false
      end

      execute "create index posts_created_month_idx on posts using btree (date_trunc('month', created_at));"
      execute "create index posts_published_month_idx on posts using btree (date_trunc('month', publication_time));"

      Post.__elasticsearch__.create_index!
    end
  end

  def down
    if Post.table_exists?
      drop_table :posts
    end
  end
end
