class Position < ApplicationRecord
  # Associations
  belongs_to :portfolio
  belongs_to :security

  # Validations
  validates :portfolio, presence: true
  validates :security, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :average_price, numericality: { greater_than: 0 }

  # Scopes
  scope :active, -> { where("quantity > 0") }
  scope :for_security, ->(security_id) { where(security_id: security_id) }

  # Instance methods
  def cost_basis
    quantity * average_price
  end

  def current_value
    latest_price = security.latest_quote&.last_price
    return nil unless latest_price
    quantity * latest_price
  end

  def unrealized_pnl
    current = current_value
    return nil unless current
    current - cost_basis
  end

  def unrealized_pnl_percentage
    return nil unless unrealized_pnl
    return 0 if cost_basis.zero?
    (unrealized_pnl / cost_basis * 100).round(2)
  end

  def add_shares(qty, price)
    # Calculate new average price
    total_cost = (quantity * average_price) + (qty * price)
    new_quantity = quantity + qty

    update!(
      quantity: new_quantity,
      average_price: total_cost / new_quantity
    )
  end

  def remove_shares(qty, sale_price)
    return false if qty > quantity

    # Calculate realized P&L
    realized_pnl = (sale_price - average_price) * qty

    new_quantity = quantity - qty

    if new_quantity.zero?
      # Close position
      update!(quantity: 0)
    else
      # Reduce position
      update!(quantity: new_quantity)
    end

    realized_pnl
  end

  def market_price
    security.latest_quote&.last_price
  end

  def price_change
    market = market_price
    return nil unless market
    market - average_price
  end

  def price_change_percentage
    change = price_change
    return nil unless change
    return 0 if average_price.zero?
    (change / average_price * 100).round(2)
  end
end
