class AlertEvent < ApplicationRecord
  belongs_to :alert_rule
end
