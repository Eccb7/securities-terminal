FactoryBot.define do
  factory :audit_log do
    actor { nil }
    action { "MyString" }
    target_type { "MyString" }
    target_id { 1 }
    payload { "" }
  end
end
