class CreateUsers < ActiveRecord::Migration[5.0]
  def up
    unless User.table_exists?
      create_table :users do |t|
        t.timestamps
        t.references :site, foreign_key: true, on_update: :cascade, on_delete: :nullify
        t.references :region, foreign_key: true, on_update: :cascade, on_delete: :nullify
        t.references :city, foreign_key: true, on_update: :cascade, on_delete: :nullify
        t.references :agent, foreign_key: true, on_update: :cascade, on_delete: :nullify
        t.inet :ip
        t.integer :external_id
        t.integer :redirect_id
        t.boolean :super_user, default: false, null: false
        t.boolean :bot, default: false, null: false
        t.boolean :verified, default: false, null: false
        t.boolean :deleted, default: false, null: false
        t.boolean :allow_login, default: true, null: false
        t.boolean :allow_posts, default: true, null: false
        t.boolean :email_confirmed, default: false, null: false
        t.boolean :phone_confirmed, default: false, null: false
        t.boolean :allow_mail, default: true, null: false
        t.boolean :show_email, default: false, null: false
        t.boolean :show_phone, default: false, null: false
        t.boolean :show_secondary_phone, default: false, null: false
        t.boolean :show_birthday, default: false, null: false
        t.boolean :show_patronymic, default: false, null: false
        t.boolean :show_skype_uid, default: false, null: false
        t.boolean :show_home_address, default: false, null: false
        t.boolean :show_about, default: false, null: false
        t.boolean :legacy_slug, default: false, null: false
        t.integer :follower_count, default: 0, null: false
        t.integer :followee_count, default: 0, null: false
        t.integer :comments_count, default: 0, null: false
        t.integer :news_count, default: 0, null: false
        t.integer :posts_count, default: 0, null: false
        t.integer :entries_count, default: 0, null: false
        t.integer :gender, limit: 2
        t.integer :marital_status, limit: 2
        t.integer :smoking_attitude, limit: 2, default: 0, null: false
        t.integer :alcohol_attitude, limit: 2, default: 0, null: false
        t.date :birthday
        t.datetime :last_seen
        t.string :notice
        t.string :slug, null: false
        t.string :screen_name
        t.string :password_digest
        t.string :legacy_password
        t.string :email
        t.string :name
        t.string :patronymic
        t.string :surname
        t.string :phone
        t.string :image
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

      add_index :users, :slug, unique: true
    end
  end

  def down
    if User.table_exists?
      drop_table :users
    end
  end
end
