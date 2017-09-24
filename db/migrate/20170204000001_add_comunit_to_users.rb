class AddComunitToUsers < ActiveRecord::Migration[5.0]
  def up
    unless column_exists?(:users, :site_id)
      change_table :users do |t|
        t.references :site, foreign_key: true, on_update: :cascade, on_delete: :nullify
        t.integer :external_id
        t.integer :redirect_id
        t.integer :news_count, default: 0, null: false
        t.integer :posts_count, default: 0, null: false
        t.integer :entries_count, default: 0, null: false
      end
    end

    unless column_exists? :user_profiles, :about
      change_table :user_profiles do |t|
        t.boolean :show_email, default: false, null: false
        t.boolean :show_phone, default: false, null: false
        t.boolean :show_secondary_phone, default: false, null: false
        t.boolean :show_birthday, default: false, null: false
        t.boolean :show_patronymic, default: false, null: false
        t.boolean :show_skype_uid, default: false, null: false
        t.boolean :show_home_address, default: false, null: false
        t.boolean :show_about, default: false, null: false
        t.integer :marital_status, limit: 2
        t.integer :smoking_attitude, limit: 2, default: 0, null: false
        t.integer :alcohol_attitude, limit: 2, default: 0, null: false
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
      remove_column :users, :external_id
      remove_column :users, :redirect_id
      remove_column :users, :news_count
      remove_column :users, :posts_count
      remove_column :users, :entries_count
    end

    if column_exists? :user_profiles, :about
      remove_column :user_profiles, :show_email
      remove_column :user_profiles, :show_phone
      remove_column :user_profiles, :show_secondary_phone
      remove_column :user_profiles, :show_birthday
      remove_column :user_profiles, :show_patronymic
      remove_column :user_profiles, :show_skype_uid
      remove_column :user_profiles, :show_home_address
      remove_column :user_profiles, :show_about
      remove_column :user_profiles, :marital_status
      remove_column :user_profiles, :smoking_attitude
      remove_column :user_profiles, :alcohol_attitude
      remove_column :user_profiles, :header_image
      remove_column :user_profiles, :home_city_name
      remove_column :user_profiles, :language_names
      remove_column :user_profiles, :country_name
      remove_column :user_profiles, :city_name
      remove_column :user_profiles, :home_address
      remove_column :user_profiles, :secondary_phone
      remove_column :user_profiles, :skype_uid
      remove_column :user_profiles, :nationality_name
      remove_column :user_profiles, :political_views
      remove_column :user_profiles, :religion_name
      remove_column :user_profiles, :about
      remove_column :user_profiles, :activities
      remove_column :user_profiles, :interests
      remove_column :user_profiles, :favorite_music
      remove_column :user_profiles, :favorite_movies
      remove_column :user_profiles, :favorite_shows
      remove_column :user_profiles, :favorite_books
      remove_column :user_profiles, :favorite_games
      remove_column :user_profiles, :favorite_quotes
      remove_column :user_profiles, :main_in_life
      remove_column :user_profiles, :main_in_people
      remove_column :user_profiles, :inspiration
    end
  end
end
