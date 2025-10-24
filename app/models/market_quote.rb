class MarketQuote < ApplicationRecord
  # Associations
  belongs_to :security

  # Validations
  validates :security, presence: true
  validates :timestamp, presence: true
  validates :last_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :bid_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :ask_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :volume, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :open_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :high_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :low_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :close_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :latest, -> { order(timestamp: :desc).limit(1) }
  scope :for_security, ->(security_id) { where(security_id: security_id) }
  scope :since, ->(time) { where("timestamp >= ?", time) }
  scope :today, -> { where("timestamp >= ?", Time.current.beginning_of_day) }

  # Instance methods
  def spread
    return nil if bid_price.nil? || ask_price.nil?
    ask_price - bid_price
  end

  def spread_percentage
    return nil if bid_price.nil? || bid_price.zero? || spread.nil?
    (spread / bid_price * 100).round(2)
  end

  def mid_price
    return nil if bid_price.nil? || ask_price.nil?
    ((bid_price + ask_price) / 2.0).round(2)
  end

  def price_change
    return nil if last_price.nil? || close_price.nil?
    last_price - close_price
  end

  def price_change_percentage
    return nil if close_price.nil? || close_price.zero? || price_change.nil?
    (price_change / close_price * 100).round(2)
  end

  def day_range
    return nil if low_price.nil? || high_price.nil?
    "#{low_price} - #{high_price}"
  end

  # Class methods
  def self.latest_for_securities(security_ids)
    where(security_id: security_ids)
      .select("DISTINCT ON (security_id) *")
      .order("security_id, timestamp DESC")
  end
end
