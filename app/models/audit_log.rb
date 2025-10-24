class AuditLog < ApplicationRecord
  # Associations
  belongs_to :actor, class_name: "User", foreign_key: "actor_id"
  belongs_to :target, polymorphic: true, optional: true

  # Validations
  validates :actor, presence: true
  validates :action, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :for_actor, ->(actor_id) { where(actor_id: actor_id) }
  scope :for_target, ->(target) { where(target: target) }
  scope :by_action, ->(action) { where(action: action) }
  scope :since, ->(time) { where("created_at >= ?", time) }
  scope :today, -> { where("created_at >= ?", Time.current.beginning_of_day) }

  # Class methods
  def self.log(actor:, action:, target: nil, payload: {})
    create!(
      actor: actor,
      action: action,
      target: target,
      payload: payload
    )
  end

  # Instance methods
  def description
    case action
    when "order_created"
      "#{actor.email} created #{payload['side']} order for #{payload['security_ticker']}"
    when "order_cancelled"
      "#{actor.email} cancelled order"
    when "order_filled"
      "Order filled: #{payload['fill_quantity']} shares at #{payload['fill_price']}"
    when "user_login"
      "#{actor.email} logged in"
    when "user_logout"
      "#{actor.email} logged out"
    when "settings_updated"
      "#{actor.email} updated settings"
    else
      "#{actor.email} performed #{action}"
    end
  end

  def target_description
    return "N/A" unless target
    "#{target.class.name} ##{target.id}"
  end
end
