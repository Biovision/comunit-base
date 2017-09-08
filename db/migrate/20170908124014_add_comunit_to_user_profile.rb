class AddComunitToUserProfile < ActiveRecord::Migration[5.1]
  def up
    add_column(:users, :search_string, :string) unless column_exists?(:users, :search_string)

    unless column_exists?(:user_profiles, :verified)
      change_table :user_profiles do |t|
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
    # Добавленные данные удалять не нужно
  end
end
