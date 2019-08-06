class InsertEditablePages < ActiveRecord::Migration[5.1]
  def up
    EditablePage.create!(slug: 'feedback', name: 'Вступление для приёмной')
    EditablePage.create!(slug: 'donate', name: 'Поддержать')
  end

  def down
    EditablePage.where(slug: %w(feedback donate)).destroy_all
  end
end
