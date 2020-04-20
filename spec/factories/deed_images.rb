FactoryBot.define do
  factory :deed_image do
    uuid { "" }
    deed { nil }
    priority { 1 }
    image { "MyString" }
    caption { "MyString" }
    description { "MyText" }
  end
end
