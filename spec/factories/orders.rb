FactoryBot.define do
  factory :order do
    user { nil }
    security { nil }
    side { "MyString" }
    order_type { "MyString" }
    price { "9.99" }
    quantity { 1 }
    filled_quantity { 1 }
    status { "MyString" }
    placed_at { "2025-10-24 16:32:36" }
    executed_at { "2025-10-24 16:32:36" }
  end
end
