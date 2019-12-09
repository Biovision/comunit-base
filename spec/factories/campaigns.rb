FactoryBot.define do
  factory :campaign do
    uuid { "" }
    region { nil }
    active { false }
    date { "2019-12-09" }
    candidates_count { 1 }
    image { "MyString" }
    name { "MyString" }
    slug { "MyString" }
    sync_state { "" }
  end
end
