Миграции
========

Здесь собраны миграции для накатывания в тех проектах, где используется
промежуточная нестабильная версия.

Для правильного изменения нужно применять их «снизу вверх».

Добавление древовидности к регионам (< 0.5.170705)
--------------------------------------------------

```bash
rails g migration add_tree_to_regions
```

```ruby
class AddTreeToRegions < ActiveRecord::Migration[5.1]
  def change
    add_column :regions, :parent_id, :integer
    add_column :regions, :latitude, :float
    add_column :regions, :longitude, :float
    add_column :regions, :long_slug, :string
    add_column :regions, :parents_cache, :string, default: '', null: false
    add_column :regions, :children_cache, :integer, array: true, default: [], null: false
    add_column :regions, :short_name, :string
    add_column :regions, :locative, :string

    add_foreign_key :regions, :regions, column: :parent_id, on_update: :cascade, on_delete: :cascade

    Region.order('id asc').each { |r| r.update! long_slug: r.slug }
    Privilege.create(slug: 'region_manager', name: 'Управляющий регионом', regional: true)
  end
end
```

Добавление типа кодов
---------------------

```bash
rails g migration update_codes
```

```ruby
class UpdateCodes < ActiveRecord::Migration[5.1]
  def change
    remove_column :codes, :category, :integer, limit: 2
    add_reference :codes, :code_type, foreign_key: true, on_update: :cascade, on_delete: :cascade
  end
end
```

Добавление голосования в модели
-------------------------------

```bash
rails g migration add_votable_to_models
```

```ruby
class AddVotableToModels < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :upvote_count, :integer, default: 0, null: false
    add_column :posts, :downvote_count, :integer, default: 0, null: false
    add_column :posts, :vote_result, :integer, default: 0, null: false

    add_column :news, :upvote_count, :integer, default: 0, null: false
    add_column :news, :downvote_count, :integer, default: 0, null: false
    add_column :news, :vote_result, :integer, default: 0, null: false

    add_column :entries, :vote_result, :integer, default: 0, null: false

    add_column :users, :upvote_count, :integer, default: 0, null: false
    add_column :users, :downvote_count, :integer, default: 0, null: false
    add_column :users, :vote_result, :integer, default: 0, null: false

    add_column :comments, :upvote_count, :integer, default: 0, null: false
    add_column :comments, :downvote_count, :integer, default: 0, null: false
    add_column :comments, :vote_result, :integer, default: 0, null: false
  end
end
```