class AddComunitToUsers < ActiveRecord::Migration[5.0]
  def up
    unless column_exists?(:users, :site_id)
      change_table :users do |t|
        t.references :site, foreign_key: true, on_update: :cascade, on_delete: :nullify
        t.references :city, foreign_key: true, on_update: :cascade, on_delete: :nullify
        t.integer :external_id
        t.integer :redirect_id
        t.boolean :verified, default: false, null: false
        t.boolean :allow_posts, default: true, null: false
        t.boolean :show_email, default: false, null: false
        t.boolean :show_phone, default: false, null: false
        t.boolean :show_secondary_phone, default: false, null: false
        t.boolean :show_birthday, default: false, null: false
        t.boolean :show_patronymic, default: false, null: false
        t.boolean :show_skype_uid, default: false, null: false
        t.boolean :show_home_address, default: false, null: false
        t.boolean :show_about, default: false, null: false
        t.boolean :legacy_slug, default: false, null: false
        t.integer :news_count, default: 0, null: false
        t.integer :posts_count, default: 0, null: false
        t.integer :entries_count, default: 0, null: false
        t.integer :marital_status, limit: 2
        t.integer :smoking_attitude, limit: 2, default: 0, null: false
        t.integer :alcohol_attitude, limit: 2, default: 0, null: false
        t.string :legacy_password
        t.string :header_image
        t.string :home_city_name
        t.string :language_names
        t.string :country_name
        t.string :city_name
        t.string :home_address
        t.string :secondary_phone
        t.string :skype_uid
        t.string :nationality_name
        t.string :political_views
        t.string :religion_name
        t.text :about
        t.text :activities
        t.text :interests
        t.text :favorite_music
        t.text :favorite_movies
        t.text :favorite_shows
        t.text :favorite_books
        t.text :favorite_games
        t.text :favorite_quotes
        t.text :main_in_life
        t.text :main_in_people
        t.text :inspiration
      end
    end
  end

  def down
    if column_exists?(:users, :site_id)
      remove_column :users, :site_id
      remove_column :users, :city_id
      remove_column :users, :external_id
      remove_column :users, :redirect_id
      remove_column :users, :verified
      remove_column :users, :allow_posts
      remove_column :users, :show_email
      remove_column :users, :show_phone
      remove_column :users, :show_secondary_phone
      remove_column :users, :show_birthday
      remove_column :users, :show_patronymic
      remove_column :users, :show_skype_uid
      remove_column :users, :show_home_address
      remove_column :users, :show_about
      remove_column :users, :legacy_slug
      remove_column :users, :news_count
      remove_column :users, :posts_count
      remove_column :users, :entries_count
      remove_column :users, :marital_status
      remove_column :users, :smoking_attitude
      remove_column :users, :alcohol_attitude
      remove_column :users, :legacy_password
      remove_column :users, :header_image
      remove_column :users, :home_city_name
      remove_column :users, :language_names
      remove_column :users, :country_name
      remove_column :users, :city_name
      remove_column :users, :home_address
      remove_column :users, :secondary_phone
      remove_column :users, :skype_uid
      remove_column :users, :nationality_name
      remove_column :users, :political_views
      remove_column :users, :religion_name
      remove_column :users, :about
      remove_column :users, :activities
      remove_column :users, :interests
      remove_column :users, :favorite_music
      remove_column :users, :favorite_movies
      remove_column :users, :favorite_shows
      remove_column :users, :favorite_books
      remove_column :users, :favorite_games
      remove_column :users, :favorite_quotes
      remove_column :users, :main_in_life
      remove_column :users, :main_in_people
      remove_column :users, :inspiration
    end
  end
end
