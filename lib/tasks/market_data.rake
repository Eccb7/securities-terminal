# Task to generate initial market data for all securities
namespace :market_data do
  desc "Generate initial market quotes for all securities"
  task simulate: :environment do
    puts "🎲 Generating market data..."

    MarketDataSimulator.generate_quotes_for_all_securities

    puts "✅ Market data generated for #{Security.active.count} securities"

    # Display sample quotes
    Security.active.limit(5).each do |security|
      quote = security.latest_quote
      if quote
        puts "  #{security.ticker}: KES #{quote.last_price} (#{quote.price_change_percentage}%)"
      end
    end
  end

  desc "Start continuous market data simulation (every 5 seconds)"
  task simulate_continuous: :environment do
    puts "🎲 Starting continuous market data simulation..."
    puts "Press Ctrl+C to stop"

    loop do
      MarketDataSimulator.generate_quotes_for_all_securities
      puts "#{Time.current.strftime('%H:%M:%S')} - Generated quotes for #{Security.active.count} securities"

      # Broadcast updates via Action Cable
      Security.active.each do |security|
        quote = security.latest_quote
        if quote
          ActionCable.server.broadcast(
            "market_channel",
            {
              type: "quote",
              ticker: security.ticker,
              bid: quote.bid,
              ask: quote.ask,
              last_price: quote.last_price,
              volume: quote.volume,
              timestamp: quote.timestamp.to_i
            }
          )
        end
      end

      # Match orders after market data update
      Security.active.each do |security|
        MatchingEngine.match_orders(security)
      end

      sleep 5
    end
  rescue Interrupt
    puts "\n✅ Simulation stopped"
  end

  desc "Match orders for all securities"
  task match_orders: :environment do
    puts "🔄 Starting order matching..."

    matched_count = 0
    Security.active.each do |security|
      puts "Matching orders for #{security.ticker}..."
      MatchingEngine.match_orders(security)
      matched_count += 1
    end

    puts "✅ Order matching completed for #{matched_count} securities!"
  end
end
