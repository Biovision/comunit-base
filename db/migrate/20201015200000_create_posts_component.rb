# frozen_string_literal: true

# Create tables for posts
class CreatePostsComponent < ActiveRecord::Migration[6.0]
  def up
    BiovisionComponent.create(slug: Biovision::Components::PostsComponent.slug)
    create_posts unless Post.table_exists?
    create_post_links unless PostLink.table_exists?
    create_post_images unless PostImage.table_exists?
    create_post_references unless PostReference.table_exists?
    create_post_attachments unless PostAttachment.table_exists?
    create_post_groups unless PostGroup.table_exists?
    create_post_group_taxa unless PostGroupTaxon.table_exists?
    create_post_taxa unless PostTaxon.table_exists?
  end
  
  def down
    BiovisionComponent[Biovision::Components::PostsComponent.slug]&.destroy
    [
      PostTaxon, PostGroupTaxon, PostGroup, PostAttachment, PostReference,
      PostImage, PostLink, Post
    ].each do |model|
      drop_table model.table_name if model.table_exists?
    end
  end

  private

  def create_posts
    create_table :posts, comment: 'Post' do |t|
      t.uuid :uuid, null: false
      t.references :user, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :simple_image, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.references :agent, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.inet :ip
      t.timestamps
      t.boolean :visible, default: true, null: false
      t.boolean :show_owner, default: true, null: false
      t.boolean :featured, default: false, null: false
      t.float :rating, default: 0.0, null: false
      t.integer :comments_count, default: 0, null: false
      t.integer :view_count, default: 0, null: false
      t.datetime :publication_time
      t.string :title, null: false
      t.string :slug, null: false, index: true
      t.string :source_name
      t.string :source_link
      t.text :lead
      t.text :body, null: false
      t.jsonb :data, default: {}, null: false
    end

    execute "create index posts_created_at_month_idx on posts using btree (date_trunc('month', created_at), user_id);"
    execute "create index posts_pubdate_month_idx on posts using btree (date_trunc('month', publication_time), user_id);"
    execute %(
      create or replace function posts_tsvector(title text, lead text, body text)
        returns tsvector as $$
          begin
            return (
              setweight(to_tsvector('russian', title), 'A') ||
              setweight(to_tsvector('russian', coalesce(lead, '')), 'B') ||
              setweight(to_tsvector('russian', body), 'C')
            );
          end
        $$ language 'plpgsql' immutable;
    )
    execute "create index posts_search_idx on posts using gin(posts_tsvector(title, lead, body));"

    add_index :posts, :uuid, unique: true
    add_index :posts, :created_at
    add_index :posts, :data, using: :gin
  end

  def create_post_links
    create_table :post_links, comment: 'Link between posts' do |t|
      t.uuid :uuid
      t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.integer :other_post_id, null: false
      t.timestamps
      t.integer :priority, limit: 2, default: 1, null: false
      t.jsonb :data, default: {}, null: false
    end

    add_index :post_links, :uuid, unique: true
    add_index :post_links, :data, using: :gin
    add_foreign_key :post_links, :posts, column: :other_post_id, on_update: :cascade, on_delete: :cascade
  end

  def create_post_images
    create_table :post_images, comment: 'Image in post gallery' do |t|
      t.uuid :uuid, null: false
      t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :simple_image, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
      t.boolean :visible, default: true, null: false
      t.integer :priority, limit: 2, default: 1, null: false
      t.text :description
      t.jsonb :data, default: {}, null: false
    end

    add_index :post_images, :uuid, unique: true
    add_index :post_images, :data, using: :gin
  end

  def create_post_references
    create_table :post_references, comment: 'Reference in post body' do |t|
      t.uuid :uuid
      t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
      t.integer :priority, limit: 2, default: 1, null: false
      t.string :authors
      t.string :title, null: false
      t.string :url
      t.string :publishing_info
      t.jsonb :data, default: {}, null: false
    end

    add_index :post_references, :uuid, unique: true
    add_index :post_references, :data, using: :gin
  end

  def create_post_notes
    create_table :post_notes, comment: 'Footnote for post' do |t|
      t.uuid :uuid
      t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
      t.integer :priority, limit: 2, default: 1, null: false
      t.text :text, null: false
      t.jsonb :data, default: {}, null: false
    end

    add_index :post_notes, :uuid, unique: true
    add_index :post_notes, :data, using: :gin
  end

  def create_post_attachments
    create_table :post_attachments, comment: 'Attachment for post' do |t|
      t.uuid :uuid, null: false
      t.references :post, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
      t.string :name
      t.string :file
      t.jsonb :data, default: {}, null: false
    end

    add_index :post_attachments, :uuid, unique: true
    add_index :post_attachments, :data, using: :gin
  end

  def create_post_groups
    create_table :post_groups, comment: 'Group of post taxonomy' do |t|
      t.integer :priority, limit: 2, default: 1, null: false
      t.boolean :visible, default: true, null: false
      t.timestamps
      t.string :slug
      t.string :name
      t.string :nav_text
    end
  end

  def create_post_group_taxa
    create_table :post_group_taxa, comment: 'Taxa in post groups' do |t|
      t.references :post_group, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :taxon, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.integer :priority, limit: 2, default: 1, null: false
    end
  end

  def create_post_taxa
    create_table :post_taxa, comment: 'Taxon attached to post' do |t|
      t.references :taxon, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
    end
  end
end
