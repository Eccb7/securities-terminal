# frozen_string_literal: true

puts "🌱 Seeding database..."

# Create NSE Exchange
puts "Creating exchange..."
nse = Exchange.find_or_create_by!(code: "NSE") do |e|
  e.name = "Nairobi Securities Exchange"
  e.timezone = "Africa/Nairobi"
  e.market_open = "09:00"
  e.market_close = "15:00"
end

# Create Organizations
puts "Creating organizations..."
demo_org = Organization.find_or_create_by!(name: "Demo Trading Firm") do |org|
  org.settings = {
    trading_enabled: true,
    max_order_value: 10_000_000,
    risk_limits: {
      daily_loss_limit: 1_000_000,
      position_concentration: 0.25
    }
  }
end

# Create Users
puts "Creating users..."
admin_user = User.find_or_create_by!(email: "admin@kenyaterminal.com") do |u|
  u.name = "System Administrator"
  u.password = "password123"
  u.role = :super_admin
  u.organization = demo_org
end

trader_user = User.find_or_create_by!(email: "trader@kenyaterminal.com") do |u|
  u.name = "Demo Trader"
  u.password = "password123"
  u.role = :trader
  u.organization = demo_org
end

# Update org admin
demo_org.update!(admin_user: admin_user)

# Create Kenyan Securities
puts "Creating Kenyan securities..."
kenyan_securities = [
  { ticker: "EQTY", name: "Equity Group Holdings PLC", instrument_type: "equity", isin: "KE0000000703" },
  { ticker: "KCB", name: "KCB Group PLC", instrument_type: "equity", isin: "KE0000000729" },
  { ticker: "SCOM", name: "Safaricom PLC", instrument_type: "equity", isin: "KE0000000281" },
  { ticker: "EABL", name: "East African Breweries Ltd", instrument_type: "equity", isin: "KE0000000232" },
  { ticker: "NCBA", name: "NCBA Group PLC", instrument_type: "equity", isin: "KE0000001794" }
]

kenyan_securities.each do |sec_data|
  Security.find_or_create_by!(ticker: sec_data[:ticker]) do |s|
    s.name = sec_data[:name]
    s.instrument_type = sec_data[:instrument_type]
    s.currency = "KES"
    s.isin = sec_data[:isin]
    s.exchange_id = nse.id
    s.lot_size = 100
    s.status = :active
  end
end

# Create Portfolios
puts "Creating portfolios..."
admin_portfolio = Portfolio.find_or_create_by!(name: "Admin Portfolio", user: admin_user, organization: demo_org) do |p|
  p.cash_balance = 1_000_000 # KES 1M starting cash
end

trader_portfolio = Portfolio.find_or_create_by!(name: "Trader Portfolio", user: trader_user, organization: demo_org) do |p|
  p.cash_balance = 500_000 # KES 500K starting cash
end

# Generate initial market data
puts "Generating initial market data..."
MarketDataSimulator.generate_quotes_for_all_securities
puts "Market data generated for #{Security.active.count} securities"

# Create demo watchlists
puts "Creating demo watchlists..."
trader_watchlist = Watchlist.find_or_create_by!(name: "Blue Chips", user: trader_user) do |w|
  # Watchlist will be created
end

# Add securities to watchlist
[ "EQTY", "KCB", "SCOM" ].each do |ticker|
  security = Security.find_by(ticker: ticker)
  if security && !trader_watchlist.watchlist_items.exists?(security: security)
    trader_watchlist.watchlist_items.create!(security: security)
  end
end

puts "\n✅ Seeding complete!"
puts "  Admin: admin@kenyaterminal.com / password123"
puts "  Trader: trader@kenyaterminal.com / password123"
puts "\n📊 Demo portfolios created:"
puts "  Admin Portfolio: KES #{admin_portfolio.cash_balance}"
puts "  Trader Portfolio: KES #{trader_portfolio.cash_balance}"
puts "\n👁️  Demo watchlist created:"
puts "  #{trader_watchlist.name}: #{trader_watchlist.watchlist_items.count} securities"
puts "\n💡 Run 'rake market_data:simulate_continuous' to start real-time simulation"
