class Security < ApplicationRecord
  # Associations
  belongs_to :exchange
  has_many :market_quotes, dependent: :destroy
  has_many :orders, dependent: :restrict_with_error
  has_many :positions, dependent: :restrict_with_error
  has_many :news_items, dependent: :nullify
  has_many :watchlist_items, dependent: :destroy
  has_many :watchlists, through: :watchlist_items

  # Enums
  enum instrument_type: {
    equity: 0,
    bond: 1,
    etf: 2,
    mutual_fund: 3,
    derivative: 4
  }

  enum status: {
    active: 0,
    suspended: 1,
    delisted: 2,
    halted: 3
  }

  # Validations
  validates :ticker, presence: true, uniqueness: { scope: :exchange_id }
  validates :name, presence: true
  validates :instrument_type, presence: true
  validates :currency, presence: true, length: { is: 3 }
  validates :lot_size, numericality: { only_integer: true, greater_than: 0 }
  validates :isin, length: { is: 12 }, allow_nil: true, uniqueness: { allow_nil: true }
  validates :status, presence: true

  # Scopes
  scope :active, -> { where(status: :active) }
  scope :tradable, -> { where(status: [ :active, :halted ]) }
  scope :by_exchange, ->(exchange_id) { where(exchange_id: exchange_id) }
  scope :by_instrument_type, ->(type) { where(instrument_type: type) }
  scope :search, ->(query) { where("ticker ILIKE ? OR name ILIKE ?", "%#{query}%", "%#{query}%") }

  # Instance methods
  def latest_quote
    market_quotes.order(timestamp: :desc).first
  end

  def display_name
    "#{ticker} - #{name}"
  end

  def tradable?
    active? || halted?
  end

  def circuit_breaker_triggered?
    halted?
  end
end
