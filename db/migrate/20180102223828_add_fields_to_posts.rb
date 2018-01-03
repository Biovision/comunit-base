class AddFieldsToPosts < ActiveRecord::Migration[5.1]
  def up
    unless column_exists?(:posts, :translation)
      add_column :posts, :translation, :boolean, default: false, null: false
    end

    add_column :posts, :meta_title, :string unless column_exists?(:posts, :meta_title)
    add_column :posts, :meta_keywords, :string unless column_exists?(:posts, :meta_keywords)
    add_column :posts, :meta_description, :string unless column_exists?(:posts, :meta_description)
    add_column :posts, :author_name, :string unless column_exists?(:posts, :author_name)
    add_column :posts, :author_title, :string unless column_exists?(:posts, :author_title)
    add_column :posts, :author_url, :string unless column_exists?(:posts, :author_url)

    unless column_exists?(:news, :translation)
      add_column :news, :translation, :boolean, default: false, null: false
    end

    add_column :news, :meta_title, :string unless column_exists?(:news, :meta_title)
    add_column :news, :meta_keywords, :string unless column_exists?(:news, :meta_keywords)
    add_column :news, :meta_description, :string unless column_exists?(:news, :meta_description)
    add_column :news, :author_name, :string unless column_exists?(:news, :author_name)
    add_column :news, :author_title, :string unless column_exists?(:news, :author_title)
    add_column :news, :author_url, :string unless column_exists?(:news, :author_url)

    unless column_exists?(:entries, :translation)
      add_column :entries, :translation, :boolean, default: false, null: false
    end

    add_column :entries, :meta_title, :string unless column_exists?(:entries, :meta_title)
    add_column :entries, :meta_keywords, :string unless column_exists?(:entries, :meta_keywords)
    add_column :entries, :meta_description, :string unless column_exists?(:entries, :meta_description)
    add_column :entries, :author_name, :string unless column_exists?(:entries, :author_name)
    add_column :entries, :author_title, :string unless column_exists?(:entries, :author_title)
    add_column :entries, :author_url, :string unless column_exists?(:entries, :author_url)
  end

  def down
  #   no rollback needed
  end
end
