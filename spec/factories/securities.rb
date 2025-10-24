FactoryBot.define do
  factory :security do
    ticker { "MyString" }
    name { "MyString" }
    instrument_type { "MyString" }
    currency { "MyString" }
    isin { "MyString" }
    lot_size { 1 }
    status { "MyString" }
  end
end
