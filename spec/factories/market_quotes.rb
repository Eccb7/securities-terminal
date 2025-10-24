FactoryBot.define do
  factory :market_quote do
    security { nil }
    bid { "9.99" }
    ask { "9.99" }
    last_price { "9.99" }
    volume { "" }
    high { "9.99" }
    low { "9.99" }
    open { "9.99" }
    close { "9.99" }
    timestamp { "2025-10-24 16:32:14" }
  end
end
