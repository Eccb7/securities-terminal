FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    name { Faker::Name.name }
    role { :trader }
    trading_restricted { false }
    association :organization

    trait :admin do
      role { :admin }
    end

    trait :super_admin do
      role { :super_admin }
    end

    trait :compliance_officer do
      role { :compliance_officer }
    end

    trait :analyst do
      role { :analyst }
    end

    trait :viewer do
      role { :viewer }
    end

    trait :restricted do
      trading_restricted { true }
    end

    trait :with_2fa do
      two_fa_enabled { true }
      two_fa_secret { ROTP::Base32.random }
    end
  end
end
