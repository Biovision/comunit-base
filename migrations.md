Миграции
========

Здесь собраны миграции для накатывания в тех проектах, где используется
промежуточная нестабильная версия.

Для правильного изменения нужно применять их «снизу вверх».

Добавление древовидности к регионам
-----------------------------------

```bash
rails g migration add_tree_to_regions
```

```ruby
class AddTreeToRegions < ActiveRecord::Migration[5.1]
  def change
    add_column :regions, :parent_id, :integer
    add_column :regions, :long_slug, :string
    add_column :regions, :parents_cache, :string, default: '', null: false
    add_column :regions, :children_cache, :integer, array: true, default: [], null: false

    add_foreign_key :regions, :regions, column: :parent_id, on_update: :cascade, on_delete: :cascade
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
