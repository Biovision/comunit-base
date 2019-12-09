FactoryBot.define do
  factory :candidate do
    uuid { "" }
    campaign { nil }
    user { nil }
    region { nil }
    agent { nil }
    ip { "" }
    visible { false }
    approved { false }
    birthday { "2019-12-09" }
    image { "MyString" }
    name { "MyString" }
    patronymic { "MyString" }
    surname { "MyString" }
    lead { "MyText" }
    about { "MyText" }
    program { "MyText" }
    data { "" }
    sync_state { "" }
  end
end
