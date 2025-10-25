class AlertEvent < ApplicationRecord
  # Associations
  belongs_to :alert_rule

  # Validations
  validates :alert_rule, presence: true
  validates :triggered_at, presence: true
  validates :actual_value, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending resolved] }

  # Scopes
  scope :pending, -> { where(status: "pending") }
  scope :resolved, -> { where(status: "resolved") }
  scope :recent, -> { order(triggered_at: :desc) }

  # Instance methods
  def resolve!(notes = nil)
    attributes = {
      status: "resolved",
      resolved_at: Time.current
    }
    attributes[:message] = notes if notes.present?
    update!(attributes)
  end

  def resolved?
    status == "resolved"
  end

  def age
    return nil unless triggered_at
    Time.current - triggered_at
  end
end
