class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  # Associations
  belongs_to :organization, optional: true
  has_many :portfolios, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :watchlists, dependent: :destroy
  has_many :audit_logs, foreign_key: :actor_id, dependent: :nullify

  # Enums
  enum :role, {
    viewer: 0,
    analyst: 1,
    trader: 2,
    compliance_officer: 3,
    admin: 4,
    super_admin: 5
  }, prefix: true

  # Validations
  validates :name, presence: true
  validates :role, presence: true

  # Scopes
  scope :active, -> { where(trading_restricted: false) }
  scope :restricted, -> { where(trading_restricted: true) }

  # Instance methods
  def can_trade?
    (trader? || admin? || super_admin?) && !trading_restricted
  end

  def enable_2fa!
    self.two_fa_secret = ROTP::Base32.random
    self.two_fa_enabled = true
    save!
  end

  def disable_2fa!
    self.two_fa_enabled = false
    self.two_fa_secret = nil
    save!
  end

  def verify_2fa_code(code)
    return false unless two_fa_enabled?
    totp = ROTP::TOTP.new(two_fa_secret)
    totp.verify(code, drift_behind: 15, drift_ahead: 15)
  end

  def admin_or_above?
    admin? || super_admin?
  end
end
