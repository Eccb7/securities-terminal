class Portfolio < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :organization
  has_many :positions, dependent: :destroy
  has_many :securities, through: :positions

  # Validations
  validates :user, presence: true
  validates :organization, presence: true
  validates :name, presence: true

  # Scopes
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :for_organization, ->(org_id) { where(organization_id: org_id) }

  # Instance methods
  def total_value
    positions.sum { |p| p.current_value || 0 }
  end

  def total_cost
    positions.sum { |p| p.cost_basis || 0 }
  end

  def unrealized_pnl
    total_value - total_cost
  end

  def unrealized_pnl_percentage
    return 0 if total_cost.zero?
    (unrealized_pnl / total_cost * 100).round(2)
  end

  def position_for_security(security_id)
    positions.find_by(security_id: security_id)
  end

  def add_position(security, quantity, price)
    position = position_for_security(security.id)

    if position
      position.add_shares(quantity, price)
    else
      positions.create!(
        security: security,
        quantity: quantity,
        average_price: price
      )
    end
  end

  def remove_position(security, quantity, price)
    position = position_for_security(security.id)
    return false unless position

    position.remove_shares(quantity, price)
  end

  def diversification_report
    total = total_value
    return [] if total.zero?

    positions.map do |position|
      {
        security: position.security,
        value: position.current_value,
        percentage: (position.current_value / total * 100).round(2)
      }
    end.sort_by { |p| -p[:percentage] }
  end
end
