# frozen_string_literal: true

# Merge posts, news and blog into single model
class ConvertPosts < ActiveRecord::Migration[5.2]
  def up
    convert_posts unless column_exists?(:post_categories, :post_type_id)
  end

  def down
    # no rollback needed
  end

  private

  # Convert old post and news categories
  def convert_posts
    @news_category_map = {}
    convert_post_categories
    update_posts
    convert_news_categories
    convert_news
    convert_blog_entries
    prepare_featured_posts
    update_counters_and_language
  end

  # Add fields to post categories and set post type for articles (was: Post)
  def convert_post_categories
    add_reference :post_categories, :post_type, foreign_key: { on_update: :cascade, on_delete: :cascade }
    add_column :post_categories, :posts_count, :integer, default: 0, null: false
    add_column :post_categories, :long_slug, :string
    add_column :post_categories, :nav_text, :string
    add_column :post_categories, :meta_description, :string
    add_column :post_categories, :data, :jsonb, default: {}, null: false

    PostCategory.update_all(post_type_id: PostType.find_by!(slug: 'article').id)
  end

  # Update posts table
  def update_posts
    change_table :posts do |t|
      t.rename :show_name, :show_owner
      t.rename :source, :source_name
      t.rename :image_author_link, :image_source_link
      t.rename :image_author_name, :image_source_name

      t.index :slug

      t.references :site, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.references :post_type, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.integer :original_post_id
      t.references :language, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.references :region, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.uuid :uuid
      t.boolean :allow_votes, default: true, null: false
      t.boolean :spam, default: false, null: false
      t.float :rating, default: 0.0, null: false
      t.integer :time_required, limit: 2, default: 0, null: false
      t.string :image_alt_text
      t.string :original_title
      t.string :translator_name
      t.text :parsed_body
      t.string :tags_cache, array: true, default: [], null: false
      t.jsonb :data, default: {}, null: false
    end

    Post.update_all(post_type_id: PostType.find_by!(slug: 'article').id)
    Post.where('image is not null').order('id asc').each do |post|
      post.image.recreate_versions! unless post.image.blank?
    end
  end

  # Copy rows from news_categories to post_categories
  def convert_news_categories
    post_type = PostType.find_by!(slug: 'news')
    NewsCategory.order('id asc').each do |old_category|
      attributes = {
        post_type: post_type,
        name: old_category.name,
        slug: old_category.slug,
        priority: old_category.priority,
        visible: old_category.visible?,
        deleted: old_category.deleted?,
        locked: old_category.locked?
      }

      new_category = PostCategory.create!(attributes)

      theme_link = ThemeNewsCategory.find_by(news_category: old_category)
      unless theme_link.blank?
        ThemePostCategory.create!(
          post_category: new_category,
          theme: theme_link.theme
        )
      end

      @news_category_map[old_category.id] = new_category.id
    end
  end

  # Copy rows in news table into posts
  def convert_news
    post_type = PostType.find_by!(slug: 'news')

    News.order('id asc').each do |item|
      attributes = {
        created_at: item.created_at,
        updated_at: item.updated_at,
        post_type: post_type,
        post_category_id: @news_category_map[item.news_category_id],
        region_id: item.region_id,
        user_id: item.user_id,
        agent_id: item.agent_id,
        ip: item.ip,
        visible: item.visible?,
        locked: item.locked?,
        deleted: item.deleted?,
        show_owner: item.show_name?,
        allow_comments: item.allow_comments?,
        view_count: item.view_count,
        publication_time: item.publication_time || item.created_at,
        title: item.title,
        slug: item.slug,
        image_name: item.image_name,
        image_source_name: item.image_author_name,
        image_source_link: item.image_author_link,
        source_name: item.source,
        source_link: item.source_link,
        lead: item.lead,
        body: item.body,
        data: {
          legacy: {
            id: item.id,
            entry_id: item.entry_id,
            author_id: item.author_id,
          }
        }
      }

      unless item.image.blank?
        attributes[:image] = Pathname.new(item.image.path).open
      end

      new_item = Post.create!(attributes)

      move_comments(item, new_item) if item.comments.any?
    end
  end

  # Copy rows from entries table into posts
  def convert_blog_entries
    post_type = PostType.find_by!(slug: 'blog_post')

    Entry.order('id asc').each do |item|
      attributes = {
        post_type: post_type,
        created_at: item.created_at,
        updated_at: item.updated_at,
        user: item.user,
        agent: item.agent,
        ip: item.ip,
        deleted: item.deleted?,
        show_owner: item.show_name?,
        view_count: item.view_count,
        publication_time: item.publication_time || item.created_at,
        title: item.title,
        slug: item.slug,
        image_name: item.image_name,
        image_source_name: item.image_author_name,
        image_source_link: item.image_author_link,
        source_name: item.source,
        source_link: item.source_link,
        lead: item.lead,
        body: item.body,
        data: {
          legacy: {
            external_id: item.external_id,
            privacy: item.privacy
          }
        }
      }

      unless item.image.blank?
        attributes[:image] = Pathname.new(item.image.path).open
      end

      new_item = Post.create!(attributes)

      move_comments(item, new_item) if item.comments.any?
    end
  end

  # Move comments from old News and Entry to new Post
  #
  # @param [News|Entry] old_item
  # @param [Post] new_item
  def move_comments(old_item, new_item)
    old_item.comments.order('id asc').each do |comment|
      comment.update!(commentable: new_item)
    end
  end

  def prepare_featured_posts
    Post.where(main_post: true).order('id desc').each do |post|
      FeaturedPost.create!(post: post)
    end
  end

  def update_counters_and_language
    PostType.order('id asc').each { |pt| PostType.reset_counters(pt.id, :posts_count) }
    PostCategory.order('id asc').each { |pc| PostCategory.reset_counters(pc.id, :posts_count) }
    Post.update_all(language_id: Language.active.first&.id)
  end
end
