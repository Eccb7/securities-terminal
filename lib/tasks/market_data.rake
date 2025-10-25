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

      sleep 5
    end
  rescue Interrupt
    puts "\n✅ Simulation stopped"
  end
end
