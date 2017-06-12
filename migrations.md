Миграции
========

Здесь собраны миграции для накатывания в тех проектах, где используется
промежуточная нестабильная версия.

Добавление типа кодов
---------------------

```ruby
class UpdateCodes < ActiveRecord::Migration[5.1]
  def change
    remove_column :codes, :category, :integer, limit: 2
    add_reference :codes, :code_type, foreign_key: true, on_update: :cascade, on_delete: :cascade
  end
end
```
