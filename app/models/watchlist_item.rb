class WatchlistItem < ApplicationRecord
  belongs_to :watchlist
  belongs_to :security
end
