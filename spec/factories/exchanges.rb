FactoryBot.define do
  factory :exchange do
    sequence(:name) { |n| "Exchange #{n}" }
    sequence(:code) { |n| "EX#{n}" }
    country { 'KE' }
    timezone { 'Africa/Nairobi' }
    currency { 'KES' }
    status { 'active' }
    market_open { '09:00' }
    market_close { '15:00' }

    trait :inactive do
      status { 'inactive' }
    end
  end
end
