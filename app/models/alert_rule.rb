class AlertRule < ApplicationRecord
  # Associations
  belongs_to :organization
  has_many :alert_events, dependent: :destroy

  # Enums
  enum rule_type: {
    price_threshold: 0,
    price_change: 1,
    volume_threshold: 2,
    volatility: 3,
    custom: 4
  }

  enum severity: {
    info: 0,
    warning: 1,
    critical: 2
  }

  # Validations
  validates :organization, presence: true
  validates :name, presence: true
  validates :rule_type, presence: true
  validates :severity, presence: true
  validates :expression, presence: true

  # Scopes
  scope :enabled, -> { where(enabled: true) }
  scope :for_organization, ->(org_id) { where(organization_id: org_id) }
  scope :by_severity, ->(severity) { where(severity: severity) }
  scope :by_type, ->(type) { where(rule_type: type) }

  # Instance methods
  def evaluate(data)
    return false unless enabled?
    
    # Expression evaluation logic would go here
    # This is a simplified placeholder
    case rule_type
    when "price_threshold"
      evaluate_price_threshold(data)
    when "price_change"
      evaluate_price_change(data)
    when "volume_threshold"
      evaluate_volume_threshold(data)
    else
      false
    end
  end

  def trigger_alert!(message, payload = {})
    alert_events.create!(
      severity: severity,
      message: message,
      payload: payload,
      triggered_at: Time.current
    )
  end

  private

  def evaluate_price_threshold(data)
    threshold = expression["threshold"]
    operator = expression["operator"]
    current_price = data[:price]
    
    case operator
    when ">"
      current_price > threshold
    when "<"
      current_price < threshold
    when ">="
      current_price >= threshold
    when "<="
      current_price <= threshold
    else
      false
    end
  end

  def evaluate_price_change(data)
    change_pct = expression["change_percentage"]
    current_change = data[:price_change_percentage]
    
    current_change.abs >= change_pct
  end

  def evaluate_volume_threshold(data)
    threshold = expression["threshold"]
    current_volume = data[:volume]
    
    current_volume > threshold
  end
end
