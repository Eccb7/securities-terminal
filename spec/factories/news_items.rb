FactoryBot.define do
  factory :news_item do
    title { "MyString" }
    body { "MyText" }
    source { "MyString" }
    published_at { "2025-10-24 16:34:45" }
    security { nil }
    tags { "" }
  end
end
