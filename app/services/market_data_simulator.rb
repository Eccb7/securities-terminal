class MarketDataSimulator
  # Simulates realistic market data for securities
  # This will be replaced with real market data feeds in production

  def self.generate_quotes_for_all_securities
    new.generate_quotes_for_all_securities
  end

  def self.generate_quote_for_security(security)
    new.generate_quote_for_security(security)
  end

  def initialize
    @timestamp = Time.current
  end

  def generate_quotes_for_all_securities
    Security.active.find_each do |security|
      generate_quote_for_security(security)
    end
  end

  def generate_quote_for_security(security)
    # Get the last quote or use base price
    last_quote = security.market_quotes.order(timestamp: :desc).first

    base_price = if last_quote&.last_price
                   last_quote.last_price
    else
                   # Default starting prices for Kenyan stocks (in KES)
                   default_price_for(security.ticker)
    end

    # Generate realistic price movement
    price_change = generate_price_change(base_price)
    new_price = (base_price + price_change).round(2)

    # Ensure price doesn't go below a minimum threshold
    new_price = [ new_price, base_price * 0.5 ].max

    # Generate bid/ask spread (0.5% - 2% of price)
    spread_percentage = rand(0.005..0.02)
    spread = (new_price * spread_percentage).round(2)

    bid_price = (new_price - spread / 2).round(2)
    ask_price = (new_price + spread / 2).round(2)

    # Generate volume (random between 100 and 100,000 shares)
    volume = rand(100..100_000) / 100 * 100 # Rounded to lot size

    # Generate OHLC data based on time of day
    ohlc_data = generate_ohlc_data(new_price, last_quote)

    # Create the market quote
    MarketQuote.create!(
      security: security,
      timestamp: @timestamp,
      last_price: new_price,
      bid_price: bid_price,
      ask_price: ask_price,
      volume: volume,
      open_price: ohlc_data[:open],
      high_price: ohlc_data[:high],
      low_price: ohlc_data[:low],
      close_price: ohlc_data[:close]
    )
  end

  private

  def default_price_for(ticker)
    # Default starting prices for Kenyan blue chips (in KES)
    prices = {
      "EQTY" => 45.50,  # Equity Group
      "KCB" => 38.25,   # KCB Group
      "SCOM" => 28.75,  # Safaricom
      "EABL" => 165.00, # EABL
      "NCBA" => 32.50   # NCBA
    }

    prices[ticker] || 50.00
  end

  def generate_price_change(base_price)
    # Generate random price change (±2% max)
    max_change_percentage = 0.02
    change_percentage = rand(-max_change_percentage..max_change_percentage)

    # Add some momentum bias (70% chance of continuing previous trend)
    if rand < 0.7
      # Bias towards small positive changes (bullish market)
      change_percentage = change_percentage.abs * (rand < 0.6 ? 1 : -1)
    end

    (base_price * change_percentage).round(2)
  end

  def generate_ohlc_data(current_price, last_quote)
    hour = Time.current.hour

    if hour == 9 || last_quote.nil? || last_quote.created_at < Time.current.beginning_of_day
      # Market just opened - set open price
      {
        open: current_price,
        high: current_price,
        low: current_price,
        close: last_quote&.close_price || current_price
      }
    elsif hour >= 15
      # Market closed - use last close
      {
        open: last_quote&.open_price || current_price,
        high: [ last_quote&.high_price || current_price, current_price ].max,
        low: [ last_quote&.low_price || current_price, current_price ].min,
        close: current_price
      }
    else
      # During trading hours - update high/low
      {
        open: last_quote&.open_price || current_price,
        high: [ last_quote&.high_price || current_price, current_price ].max,
        low: [ last_quote&.low_price || current_price, current_price ].min,
        close: last_quote&.close_price || current_price
      }
    end
  end
end
