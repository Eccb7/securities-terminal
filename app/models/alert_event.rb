class AlertEvent < ApplicationRecord
  # Associations
  belongs_to :alert_rule

  # Enums
  enum severity: {
    info: 0,
    warning: 1,
    critical: 2
  }

  # Validations
  validates :alert_rule, presence: true
  validates :severity, presence: true
  validates :message, presence: true
  validates :triggered_at, presence: true

  # Scopes
  scope :unresolved, -> { where(resolved: false) }
  scope :resolved, -> { where(resolved: true) }
  scope :recent, -> { order(triggered_at: :desc) }
  scope :critical, -> { where(severity: :critical) }
  scope :by_severity, ->(severity) { where(severity: severity) }

  # Instance methods
  def resolve!(notes = nil)
    update!(
      resolved: true,
      resolved_at: Time.current,
      resolution_notes: notes
    )
  end

  def age
    return nil unless triggered_at
    Time.current - triggered_at
  end

  def age_in_words
    return nil unless triggered_at
    distance_of_time_in_words(triggered_at, Time.current)
  end
end
