class Organization < ApplicationRecord
  # Associations
  has_many :users, dependent: :restrict_with_error
  belongs_to :admin_user, class_name: "User", optional: true

  # Validations
  validates :name, presence: true, uniqueness: true

  # Default settings
  after_initialize :set_default_settings, if: :new_record?

  private

  def set_default_settings
    self.settings ||= {
      trading_enabled: true,
      max_order_value: 10_000_000, # KES
      risk_limits: {
        daily_loss_limit: 1_000_000,
        position_concentration: 0.25
      }
    }
  end
end
