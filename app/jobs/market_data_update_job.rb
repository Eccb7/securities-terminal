class MarketDataUpdateJob
  include Sidekiq::Job

  # Run this job every 5 seconds during market hours
  sidekiq_options queue: :market_data, retry: 3

  def perform
    # Check if market is open (9 AM - 3 PM EAT on weekdays)
    return unless market_open?

    # Generate new quotes for all active securities
    MarketDataSimulator.generate_quotes_for_all_securities

    # Broadcast updates via Action Cable
    broadcast_market_updates
  end

  private

  def market_open?
    now = Time.current.in_time_zone("Africa/Nairobi")

    # Check if it's a weekday
    return false unless (1..5).include?(now.wday)

    # Check if it's during market hours (9 AM - 3 PM)
    hour = now.hour
    hour >= 9 && hour < 15
  end

  def broadcast_market_updates
    # Get latest quotes for all securities
    securities = Security.active.includes(:market_quotes)

    securities.each do |security|
      latest_quote = security.latest_quote
      next unless latest_quote

      # Broadcast to MarketChannel
      ActionCable.server.broadcast(
        "market_channel",
        {
          type: "quote_update",
          security_id: security.id,
          ticker: security.ticker,
          quote: quote_json(latest_quote)
        }
      )
    end
  end

  def quote_json(quote)
    {
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
