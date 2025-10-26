FactoryBot.define do
  factory :security do
    sequence(:ticker) { |n| "TST#{n}" }
    sequence(:name) { |n| "Test Security #{n}" }
    instrument_type { 'equity' }
    currency { 'KES' }
    status { 'active' }
    isin { Faker::Alphanumeric.alphanumeric(number: 12).upcase }
    lot_size { 1 }
    association :exchange

    trait :bond do
      instrument_type { 'bond' }
    end

    trait :etf do
      instrument_type { 'etf' }
    end

    trait :suspended do
      status { 'suspended' }
    end

    trait :delisted do
      status { 'delisted' }
    end
  end
end
