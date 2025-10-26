class DashboardController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    @portfolios = current_user.portfolios.includes(:positions)
    @watchlists = current_user.watchlists.includes(:securities)
    @recent_orders = current_user.orders.recent.limit(10)
    @recent_news = NewsItem.recent.limit(5)
    @alert_events = current_user.alert_rules.includes(:alert_events).flat_map(&:alert_events).select(&:unresolved?).sort_by(&:triggered_at).reverse.first(5)

    # Market overview - top securities by volume
    @market_overview = Security.active
                               .joins(:market_quotes)
                               .group("securities.id")
                               .order("SUM(market_quotes.volume) DESC")
                               .limit(10)
  end

  def market_data
    # Real-time market data endpoint for dashboard updates
    @securities = Security.active.includes(:market_quotes)
    @quotes = MarketQuote.latest_for_securities(@securities.pluck(:id))

    render json: {
      quotes: @quotes.map { |q| quote_json(q) },
      timestamp: Time.current.iso8601
    }
  end

  private

  def quote_json(quote)
    {
      security_id: quote.security_id,
      ticker: quote.security.ticker,
      last_price: quote.last_price,
      bid_price: quote.bid_price,
      ask_price: quote.ask_price,
      volume: quote.volume,
      price_change: quote.price_change,
      price_change_pct: quote.price_change_percentage,
      timestamp: quote.timestamp.iso8601
    }
  end
end
