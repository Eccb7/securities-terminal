class Order < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :security

  # Enums
  enum :side, {
    buy: 0,
    sell: 1
  }

  enum :order_type, {
    market: 0,
    limit: 1,
    stop: 2,
    stop_limit: 3
  }, prefix: :type

  enum :status, {
    pending: 0,
    open: 1,
    partially_filled: 2,
    filled: 3,
    cancelled: 4,
    rejected: 5,
    expired: 6
  }

  enum :time_in_force, {
    day: 0,
    gtc: 1,      # Good Till Cancelled
    ioc: 2,      # Immediate or Cancel
    fok: 3       # Fill or Kill
  }

  # Validations
  validates :user, presence: true
  validates :security, presence: true
  validates :side, presence: true
  validates :order_type, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :price, numericality: { greater_than: 0 }, if: -> { type_limit? || type_stop_limit? }
  validates :stop_price, numericality: { greater_than: 0 }, if: -> { type_stop? || type_stop_limit? }
  validates :status, presence: true
  validates :time_in_force, presence: true
  validate :validate_lot_size
  validate :validate_filled_quantity

  # Callbacks
  before_validation :set_defaults, on: :create
  after_create :log_order_creation

  # Scopes
  scope :active, -> { where(status: [ :pending, :open, :partially_filled ]) }
  scope :completed, -> { where(status: [ :filled, :cancelled, :rejected, :expired ]) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :for_security, ->(security_id) { where(security_id: security_id) }
  scope :buys, -> { where(side: :buy) }
  scope :sells, -> { where(side: :sell) }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def remaining_quantity
    quantity - (filled_quantity || 0)
  end

  def fill_percentage
    return 0 if quantity.zero?
    ((filled_quantity || 0).to_f / quantity * 100).round(2)
  end

  def can_cancel?
    pending? || open? || partially_filled?
  end

  def can_modify?
    pending? || open?
  end

  def total_value
    return nil unless price && quantity
    price * quantity
  end

  def average_fill_price
    return nil unless filled_quantity&.positive? && avg_fill_price
    avg_fill_price
  end

  def cancel!
    return false unless can_cancel?

    update!(status: :cancelled, cancelled_at: Time.current)
    log_order_cancellation
    true
  end

  def reject!(reason = nil)
    update!(
      status: :rejected,
      rejected_at: Time.current,
      rejection_reason: reason
    )
    log_order_rejection(reason)
  end

  def fill!(fill_price, fill_qty)
    self.filled_quantity ||= 0
    self.filled_quantity += fill_qty

    # Calculate average fill price
    if avg_fill_price.nil?
      self.avg_fill_price = fill_price
    else
      total_cost = (avg_fill_price * (filled_quantity - fill_qty)) + (fill_price * fill_qty)
      self.avg_fill_price = total_cost / filled_quantity
    end

    # Update status based on filled quantity
    if filled_quantity >= quantity
      self.status = :filled
      self.filled_at = Time.current
    elsif filled_quantity > 0
      self.status = :partially_filled
    end

    save!
    log_order_fill(fill_price, fill_qty)
  end

  private

  def set_defaults
    self.status ||= :pending
    self.time_in_force ||= :day
    self.filled_quantity ||= 0
  end

  def validate_lot_size
    return unless security && quantity

    lot_size = security.lot_size || 1
    if quantity % lot_size != 0
      errors.add(:quantity, "must be a multiple of lot size (#{lot_size})")
    end
  end

  def validate_filled_quantity
    return unless filled_quantity && quantity

    if filled_quantity > quantity
      errors.add(:filled_quantity, "cannot exceed order quantity")
    end
  end

  def log_order_creation
    AuditLog.create!(
      actor: user,
      action: "order_created",
      target: self,
      payload: {
        side: side,
        order_type: order_type,
        security_ticker: security.ticker,
        quantity: quantity,
        price: price
      }
    )
  end

  def log_order_cancellation
    AuditLog.create!(
      actor: user,
      action: "order_cancelled",
      target: self,
      payload: {
        remaining_quantity: remaining_quantity
      }
    )
  end

  def log_order_rejection(reason)
    AuditLog.create!(
      actor: user,
      action: "order_rejected",
      target: self,
      payload: {
        reason: reason
      }
    )
  end

  def log_order_fill(fill_price, fill_qty)
    AuditLog.create!(
      actor: user,
      action: "order_filled",
      target: self,
      payload: {
        fill_price: fill_price,
        fill_quantity: fill_qty,
        filled_quantity: filled_quantity,
        status: status
      }
    )
  end
end
