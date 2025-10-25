class AlertRule < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :security
  has_many :alert_events, dependent: :destroy

  # Validations
  validates :user, presence: true
  validates :security, presence: true
  validates :condition_type, presence: true, inclusion: { in: %w[price volume percent_change] }
  validates :comparison_operator, presence: true, inclusion: { in: %w[greater_than less_than equals] }
  validates :threshold_value, presence: true, numericality: true
  validates :notification_method, presence: true, inclusion: { in: %w[email in_app both] }
  validates :status, presence: true, inclusion: { in: %w[active inactive triggered] }

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :inactive, -> { where(status: "inactive") }
  scope :triggered, -> { where(status: "triggered") }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :for_security, ->(security_id) { where(security_id: security_id) }

  # Instance methods
  def condition_met?(actual_value)
    case comparison_operator
    when "greater_than"
      actual_value > threshold_value
    when "less_than"
      actual_value < threshold_value
    when "equals"
      (actual_value - threshold_value).abs < 0.01
    else
      false
    end
  end

  def trigger!(actual_value, message: nil)
    transaction do
      update!(status: "triggered")
      alert_events.create!(
        triggered_at: Time.current,
        actual_value: actual_value,
        status: "pending",
        message: message || build_alert_message(actual_value)
      )
    end
  end

  private

  def build_alert_message(actual_value)
    "#{security.ticker} #{condition_type} #{comparison_operator.gsub('_', ' ')} #{threshold_value} (actual: #{actual_value})"
  end
end
