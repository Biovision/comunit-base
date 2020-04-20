FactoryBot.define do
  factory :deed do
    uuid { "" }
    user { nil }
    agent { nil }
    ip { "" }
    offer { false }
    done { false }
    visible { false }
    comments_count { 1 }
    image { "MyString" }
    title { "MyString" }
    description { "MyText" }
    data { "" }
  end
end
