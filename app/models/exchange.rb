class Exchange < ApplicationRecord
  # Associations
  has_many :securities, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true, length: { maximum: 10 }
  validates :country, presence: true
  validates :currency, presence: true, length: { is: 3 }
  validates :timezone, presence: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_country, ->(country) { where(country: country) }

  # Instance methods
  def display_name
    "#{name} (#{code})"
  end

  def market_open?(time = Time.current)
    return false unless active?
    return false if trading_hours.blank?

    # Check if time is within trading hours (this is a simplified version)
    # Real implementation would check timezone, holidays, etc.
    hour = time.in_time_zone(timezone).hour
    trading_hours.dig("open").to_i <= hour && hour < trading_hours.dig("close").to_i
  end

  def active_securities_count
    securities.active.count
  end
end
