# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170218000000) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agents", force: :cascade do |t|
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "browser_id"
    t.boolean  "bot",        default: false, null: false
    t.boolean  "mobile",     default: false, null: false
    t.boolean  "active",     default: true,  null: false
    t.boolean  "locked",     default: false, null: false
    t.boolean  "deleted",    default: false, null: false
    t.string   "name",                       null: false
    t.index ["browser_id"], name: "index_agents_on_browser_id", using: :btree
    t.index ["name"], name: "index_agents_on_name", using: :btree
  end

  create_table "browsers", force: :cascade do |t|
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "bot",          default: false, null: false
    t.boolean  "mobile",       default: false, null: false
    t.boolean  "active",       default: true,  null: false
    t.boolean  "locked",       default: false, null: false
    t.boolean  "deleted",      default: false, null: false
    t.integer  "agents_count", default: 0,     null: false
    t.string   "name",                         null: false
  end

  create_table "cities", force: :cascade do |t|
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "region_id",                    null: false
    t.boolean  "visible",      default: true,  null: false
    t.boolean  "locked",       default: false, null: false
    t.integer  "users_count",  default: 0,     null: false
    t.integer  "news_count",   default: 0,     null: false
    t.string   "slug",                         null: false
    t.string   "name",                         null: false
    t.string   "image"
    t.string   "header_image"
    t.index ["region_id"], name: "index_cities_on_region_id", using: :btree
  end

  create_table "codes", force: :cascade do |t|
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "user_id"
    t.integer  "agent_id"
    t.inet     "ip"
    t.integer  "category",   limit: 2,             null: false
    t.integer  "quantity",   limit: 2, default: 1, null: false
    t.string   "body",                             null: false
    t.string   "payload"
    t.index ["agent_id"], name: "index_codes_on_agent_id", using: :btree
    t.index ["user_id"], name: "index_codes_on_user_id", using: :btree
  end

  create_table "comments", force: :cascade do |t|
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "parent_id"
    t.integer  "user_id"
    t.integer  "agent_id"
    t.inet     "ip"
    t.boolean  "visible",          default: true,  null: false
    t.boolean  "locked",           default: false, null: false
    t.boolean  "deleted",          default: false, null: false
    t.integer  "commentable_id",                   null: false
    t.string   "commentable_type",                 null: false
    t.text     "body",                             null: false
    t.index ["agent_id"], name: "index_comments_on_agent_id", using: :btree
    t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

  create_table "editable_pages", force: :cascade do |t|
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "slug",                     null: false
    t.string   "name",                     null: false
    t.string   "image"
    t.string   "title",       default: "", null: false
    t.string   "keywords",    default: "", null: false
    t.string   "description", default: "", null: false
    t.text     "body",        default: "", null: false
  end

  create_table "entries", force: :cascade do |t|
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "external_id"
    t.integer  "user_id"
    t.integer  "agent_id"
    t.inet     "ip"
    t.integer  "community_id"
    t.boolean  "deleted",                     default: false, null: false
    t.boolean  "show_name",                   default: true,  null: false
    t.integer  "privacy",           limit: 2, default: 0,     null: false
    t.integer  "comments_count",              default: 0,     null: false
    t.integer  "view_count",                  default: 0,     null: false
    t.integer  "rating",                      default: 0,     null: false
    t.integer  "upvote_count",                default: 0,     null: false
    t.integer  "downvote_count",              default: 0,     null: false
    t.datetime "publication_time"
    t.string   "title"
    t.string   "slug"
    t.string   "image"
    t.string   "image_name"
    t.string   "image_author_name"
    t.string   "image_author_link"
    t.string   "source"
    t.string   "source_link"
    t.text     "lead"
    t.text     "body",                                        null: false
    t.index "date_trunc('month'::text, created_at)", name: "entries_created_month_idx", using: :btree
    t.index "date_trunc('month'::text, publication_time)", name: "entries_published_month_idx", using: :btree
    t.index ["agent_id"], name: "index_entries_on_agent_id", using: :btree
    t.index ["user_id"], name: "index_entries_on_user_id", using: :btree
  end

  create_table "illustrations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
    t.string   "name"
    t.string   "image"
    t.index ["user_id"], name: "index_illustrations_on_user_id", using: :btree
  end

  create_table "metric_values", force: :cascade do |t|
    t.integer  "metric_id",             null: false
    t.datetime "time",                  null: false
    t.integer  "quantity",  default: 1, null: false
    t.index "date_trunc('day'::text, \"time\")", name: "metric_values_day_idx", using: :btree
    t.index ["metric_id"], name: "index_metric_values_on_metric_id", using: :btree
  end

  create_table "metrics", force: :cascade do |t|
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "incremental",                 default: false, null: false
    t.boolean  "start_with_zero",             default: false, null: false
    t.boolean  "show_on_dashboard",           default: true,  null: false
    t.integer  "default_period",    limit: 2, default: 7,     null: false
    t.integer  "value",                       default: 0,     null: false
    t.integer  "previous_value",              default: 0,     null: false
    t.string   "name",                                        null: false
    t.string   "description",                 default: "",    null: false
  end

  create_table "news", force: :cascade do |t|
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "external_id"
    t.integer  "user_id"
    t.integer  "news_category_id"
    t.integer  "region_id"
    t.integer  "agent_id"
    t.inet     "ip"
    t.boolean  "visible",                     default: true,  null: false
    t.boolean  "locked",                      default: false, null: false
    t.boolean  "deleted",                     default: false, null: false
    t.boolean  "approved",                    default: true,  null: false
    t.boolean  "show_name",                   default: true,  null: false
    t.boolean  "allow_comments",              default: true,  null: false
    t.integer  "post_type",         limit: 2, default: 0,     null: false
    t.integer  "entry_id"
    t.integer  "author_id"
    t.integer  "comments_count",              default: 0,     null: false
    t.integer  "view_count",                  default: 0,     null: false
    t.datetime "publication_time"
    t.string   "title",                                       null: false
    t.string   "slug",                                        null: false
    t.string   "image"
    t.string   "image_name"
    t.string   "image_author_name"
    t.string   "image_author_link"
    t.string   "source"
    t.string   "source_link"
    t.text     "lead"
    t.text     "body",                                        null: false
    t.index "date_trunc('month'::text, created_at)", name: "news_created_month_idx", using: :btree
    t.index "date_trunc('month'::text, publication_time)", name: "news_published_month_idx", using: :btree
    t.index ["agent_id"], name: "index_news_on_agent_id", using: :btree
    t.index ["news_category_id"], name: "index_news_on_news_category_id", using: :btree
    t.index ["region_id"], name: "index_news_on_region_id", using: :btree
    t.index ["user_id"], name: "index_news_on_user_id", using: :btree
  end

  create_table "news_categories", force: :cascade do |t|
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "external_id"
    t.integer  "priority",    limit: 2, default: 1,     null: false
    t.integer  "items_count",           default: 0,     null: false
    t.boolean  "locked",                default: false, null: false
    t.boolean  "deleted",               default: false, null: false
    t.boolean  "visible",               default: true,  null: false
    t.string   "name",                                  null: false
    t.string   "slug",                                  null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "user_id",                                    null: false
    t.integer  "category",         limit: 2,                 null: false
    t.integer  "payload"
    t.integer  "repetition_count",           default: 1,     null: false
    t.boolean  "read_by_user",               default: false, null: false
    t.index ["user_id"], name: "index_notifications_on_user_id", using: :btree
  end

  create_table "post_categories", force: :cascade do |t|
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "external_id"
    t.integer  "parent_id"
    t.integer  "priority",       default: 1,     null: false
    t.integer  "items_count",    default: 0,     null: false
    t.boolean  "locked",         default: false, null: false
    t.boolean  "deleted",        default: false, null: false
    t.boolean  "visible",        default: true,  null: false
    t.string   "name",                           null: false
    t.string   "slug",                           null: false
    t.string   "parents_cache",  default: "",    null: false
    t.integer  "children_cache", default: [],    null: false, array: true
  end

  create_table "posts", force: :cascade do |t|
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "external_id"
    t.integer  "user_id"
    t.integer  "post_category_id"
    t.integer  "agent_id"
    t.inet     "ip"
    t.boolean  "visible",           default: true,  null: false
    t.boolean  "locked",            default: false, null: false
    t.boolean  "deleted",           default: false, null: false
    t.boolean  "approved",          default: true,  null: false
    t.boolean  "show_name",         default: true,  null: false
    t.boolean  "allow_comments",    default: true,  null: false
    t.boolean  "main_post",         default: false, null: false
    t.integer  "entry_id"
    t.integer  "author_id"
    t.integer  "comments_count",    default: 0,     null: false
    t.integer  "view_count",        default: 0,     null: false
    t.datetime "publication_time"
    t.string   "title",                             null: false
    t.string   "slug",                              null: false
    t.string   "image"
    t.string   "image_name"
    t.string   "image_author_name"
    t.string   "image_author_link"
    t.string   "source"
    t.string   "source_link"
    t.text     "lead"
    t.text     "body",                              null: false
    t.index "date_trunc('month'::text, created_at)", name: "posts_created_month_idx", using: :btree
    t.index "date_trunc('month'::text, publication_time)", name: "posts_published_month_idx", using: :btree
    t.index ["agent_id"], name: "index_posts_on_agent_id", using: :btree
    t.index ["post_category_id"], name: "index_posts_on_post_category_id", using: :btree
    t.index ["user_id"], name: "index_posts_on_user_id", using: :btree
  end

  create_table "privileges", force: :cascade do |t|
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "external_id"
    t.integer  "parent_id"
    t.boolean  "locked",                   default: false, null: false
    t.boolean  "deleted",                  default: false, null: false
    t.boolean  "regional",                 default: false, null: false
    t.integer  "priority",       limit: 2, default: 1,     null: false
    t.integer  "users_count",              default: 0,     null: false
    t.string   "parents_cache",            default: "",    null: false
    t.integer  "children_cache",           default: [],    null: false, array: true
    t.string   "name",                                     null: false
    t.string   "slug",                                     null: false
    t.string   "description",              default: "",    null: false
  end

  create_table "regions", force: :cascade do |t|
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "visible",      default: true,  null: false
    t.boolean  "locked",       default: false, null: false
    t.integer  "users_count",  default: 0,     null: false
    t.integer  "cities_count", default: 0,     null: false
    t.integer  "news_count",   default: 0,     null: false
    t.string   "slug",                         null: false
    t.string   "name",                         null: false
    t.string   "image"
    t.string   "header_image"
  end

  create_table "sites", force: :cascade do |t|
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "active",      default: true,  null: false
    t.boolean  "deleted",     default: false, null: false
    t.boolean  "has_regions", default: false, null: false
    t.integer  "users_count", default: 0,     null: false
    t.string   "name",                        null: false
    t.string   "host",                        null: false
    t.string   "image"
    t.string   "description"
  end

  create_table "theme_news_categories", force: :cascade do |t|
    t.integer "theme_id",         null: false
    t.integer "news_category_id", null: false
    t.index ["news_category_id"], name: "index_theme_news_categories_on_news_category_id", using: :btree
    t.index ["theme_id"], name: "index_theme_news_categories_on_theme_id", using: :btree
  end

  create_table "theme_post_categories", force: :cascade do |t|
    t.integer "theme_id",         null: false
    t.integer "post_category_id", null: false
    t.index ["post_category_id"], name: "index_theme_post_categories_on_post_category_id", using: :btree
    t.index ["theme_id"], name: "index_theme_post_categories_on_theme_id", using: :btree
  end

  create_table "themes", force: :cascade do |t|
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.boolean  "locked",                          default: false, null: false
    t.integer  "post_categories_count", limit: 2, default: 0,     null: false
    t.integer  "news_categories_count", limit: 2, default: 0,     null: false
    t.string   "name",                                            null: false
    t.string   "slug",                                            null: false
  end

  create_table "tokens", force: :cascade do |t|
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.datetime "last_used"
    t.integer  "user_id",                   null: false
    t.integer  "agent_id"
    t.inet     "ip"
    t.boolean  "active",     default: true, null: false
    t.string   "token",                     null: false
    t.index ["agent_id"], name: "index_tokens_on_agent_id", using: :btree
    t.index ["user_id"], name: "index_tokens_on_user_id", using: :btree
  end

  create_table "user_links", force: :cascade do |t|
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "agent_id"
    t.inet     "ip"
    t.integer  "follower_id",                null: false
    t.integer  "followee_id",                null: false
    t.boolean  "visible",     default: true, null: false
    t.index ["agent_id"], name: "index_user_links_on_agent_id", using: :btree
  end

  create_table "user_messages", force: :cascade do |t|
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "agent_id"
    t.inet     "ip"
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.boolean  "read_by_receiver",    default: false, null: false
    t.boolean  "deleted_by_sender",   default: false, null: false
    t.boolean  "deleted_by_receiver", default: false, null: false
    t.text     "body",                                null: false
    t.index ["agent_id"], name: "index_user_messages_on_agent_id", using: :btree
  end

  create_table "user_privileges", force: :cascade do |t|
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "user_id",      null: false
    t.integer  "privilege_id", null: false
    t.integer  "region_id"
    t.index ["privilege_id"], name: "index_user_privileges_on_privilege_id", using: :btree
    t.index ["region_id"], name: "index_user_privileges_on_region_id", using: :btree
    t.index ["user_id"], name: "index_user_privileges_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "site_id"
    t.integer  "region_id"
    t.integer  "city_id"
    t.integer  "agent_id"
    t.inet     "ip"
    t.integer  "external_id"
    t.integer  "redirect_id"
    t.boolean  "super_user",                     default: false, null: false
    t.boolean  "bot",                            default: false, null: false
    t.boolean  "verified",                       default: false, null: false
    t.boolean  "deleted",                        default: false, null: false
    t.boolean  "allow_login",                    default: true,  null: false
    t.boolean  "allow_posts",                    default: true,  null: false
    t.boolean  "email_confirmed",                default: false, null: false
    t.boolean  "phone_confirmed",                default: false, null: false
    t.boolean  "allow_mail",                     default: true,  null: false
    t.boolean  "show_email",                     default: false, null: false
    t.boolean  "show_phone",                     default: false, null: false
    t.boolean  "show_secondary_phone",           default: false, null: false
    t.boolean  "show_birthday",                  default: false, null: false
    t.boolean  "show_patronymic",                default: false, null: false
    t.boolean  "show_skype_uid",                 default: false, null: false
    t.boolean  "show_home_address",              default: false, null: false
    t.boolean  "show_about",                     default: false, null: false
    t.boolean  "legacy_slug",                    default: false, null: false
    t.integer  "follower_count",                 default: 0,     null: false
    t.integer  "followee_count",                 default: 0,     null: false
    t.integer  "comments_count",                 default: 0,     null: false
    t.integer  "news_count",                     default: 0,     null: false
    t.integer  "posts_count",                    default: 0,     null: false
    t.integer  "entries_count",                  default: 0,     null: false
    t.integer  "gender",               limit: 2
    t.integer  "marital_status",       limit: 2
    t.integer  "smoking_attitude",     limit: 2, default: 0,     null: false
    t.integer  "alcohol_attitude",     limit: 2, default: 0,     null: false
    t.date     "birthday"
    t.datetime "last_seen"
    t.string   "notice"
    t.string   "slug",                                           null: false
    t.string   "screen_name"
    t.string   "password_digest"
    t.string   "legacy_password"
    t.string   "email"
    t.string   "name"
    t.string   "patronymic"
    t.string   "surname"
    t.string   "phone"
    t.string   "image"
    t.string   "header_image"
    t.string   "home_city_name"
    t.string   "language_names"
    t.string   "country_name"
    t.string   "city_name"
    t.string   "home_address"
    t.string   "secondary_phone"
    t.string   "skype_uid"
    t.string   "nationality_name"
    t.string   "political_views"
    t.string   "religion_name"
    t.text     "about"
    t.text     "activities"
    t.text     "interests"
    t.text     "favorite_music"
    t.text     "favorite_movies"
    t.text     "favorite_shows"
    t.text     "favorite_books"
    t.text     "favorite_games"
    t.text     "favorite_quotes"
    t.text     "main_in_life"
    t.text     "main_in_people"
    t.text     "inspiration"
    t.index ["agent_id"], name: "index_users_on_agent_id", using: :btree
    t.index ["city_id"], name: "index_users_on_city_id", using: :btree
    t.index ["region_id"], name: "index_users_on_region_id", using: :btree
    t.index ["site_id"], name: "index_users_on_site_id", using: :btree
    t.index ["slug"], name: "index_users_on_slug", unique: true, using: :btree
  end

  add_foreign_key "agents", "browsers"
  add_foreign_key "cities", "regions"
  add_foreign_key "codes", "agents"
  add_foreign_key "codes", "users"
  add_foreign_key "comments", "agents"
  add_foreign_key "comments", "comments", column: "parent_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "comments", "users"
  add_foreign_key "entries", "agents"
  add_foreign_key "entries", "users"
  add_foreign_key "illustrations", "users"
  add_foreign_key "metric_values", "metrics"
  add_foreign_key "news", "agents"
  add_foreign_key "news", "news_categories"
  add_foreign_key "news", "regions"
  add_foreign_key "news", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "post_categories", "post_categories", column: "parent_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "posts", "agents"
  add_foreign_key "posts", "post_categories"
  add_foreign_key "posts", "users"
  add_foreign_key "theme_news_categories", "news_categories"
  add_foreign_key "theme_news_categories", "themes"
  add_foreign_key "theme_post_categories", "post_categories"
  add_foreign_key "theme_post_categories", "themes"
  add_foreign_key "tokens", "agents"
  add_foreign_key "tokens", "users"
  add_foreign_key "user_links", "agents"
  add_foreign_key "user_links", "users", column: "followee_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "user_links", "users", column: "follower_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "user_messages", "agents"
  add_foreign_key "user_messages", "users", column: "receiver_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "user_messages", "users", column: "sender_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "user_privileges", "privileges"
  add_foreign_key "user_privileges", "regions"
  add_foreign_key "user_privileges", "users"
  add_foreign_key "users", "agents"
  add_foreign_key "users", "cities"
  add_foreign_key "users", "regions"
  add_foreign_key "users", "sites"
end
