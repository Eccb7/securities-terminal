class WatchlistItem < ApplicationRecord
  # Associations
  belongs_to :watchlist
  belongs_to :security

  # Validations
  validates :watchlist, presence: true
  validates :security, presence: true
  validates :security_id, uniqueness: { scope: :watchlist_id }

  # Scopes
  scope :for_watchlist, ->(watchlist_id) { where(watchlist_id: watchlist_id) }
  scope :for_security, ->(security_id) { where(security_id: security_id) }
end
