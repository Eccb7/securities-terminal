FactoryBot.define do
  factory :alert_rule do
    name { "MyString" }
    rule_type { "MyString" }
    severity { "MyString" }
    expression { "" }
    enabled { false }
    organization { nil }
  end
end
