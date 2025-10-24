FactoryBot.define do
  factory :position do
    portfolio { nil }
    security { nil }
    quantity { 1 }
    avg_price { "9.99" }
  end
end
