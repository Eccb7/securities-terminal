class Watchlist < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :watchlist_items, dependent: :destroy
  has_many :securities, through: :watchlist_items

  # Validations
  validates :user, presence: true
  validates :name, presence: true

  # Scopes
  scope :for_user, ->(user_id) { where(user_id: user_id) }

  # Instance methods
  def add_security(security)
    return false if securities.include?(security)
    watchlist_items.create(security: security)
  end

  def remove_security(security)
    watchlist_items.find_by(security: security)&.destroy
  end

  def includes_security?(security)
    securities.include?(security)
  end

  def securities_with_quotes
    securities.includes(:market_quotes).map do |security|
      {
        security: security,
        latest_quote: security.latest_quote
      }
    end
  end
end
