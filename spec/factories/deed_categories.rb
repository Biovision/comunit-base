FactoryBot.define do
  factory :deed_category do
    uuid { "" }
    parent_id { 1 }
    priority { 1 }
    visible { false }
    deeds_count { 1 }
    name { "MyString" }
    parents_cache { "MyString" }
    children_cache { 1 }
  end
end
