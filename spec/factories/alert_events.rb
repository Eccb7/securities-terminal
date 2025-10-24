FactoryBot.define do
  factory :alert_event do
    alert_rule { nil }
    severity { "MyString" }
    payload { "" }
    resolved { false }
    resolved_at { "2025-10-24 16:34:19" }
    message { "MyText" }
  end
end
