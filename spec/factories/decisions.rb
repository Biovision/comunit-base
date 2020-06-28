FactoryBot.define do
  factory :decision do
    simple_image { nil }
    uuid { "" }
    active { false }
    visible { false }
    end_date { "2020-06-04" }
    name { "MyString" }
    body { "MyText" }
    answers { "" }
    data { "" }
  end
end
