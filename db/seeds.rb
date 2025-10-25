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
admin_user = User.find_or_create_by!(email: "admin@terminal.com") do |u|
  u.name = "System Administrator"
  u.password = "password123"
  u.role = :super_admin
  u.organization = demo_org
end

trader_user = User.find_or_create_by!(email: "trader@terminal.com") do |u|
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

# Create sample news items
puts "Creating sample news items..."
news_data = [
  {
    security: Security.find_by(ticker: "EQTY"),
    title: "Equity Group Reports Strong Q3 2025 Earnings",
    summary: "Equity Group Holdings posts 23% increase in profit before tax to KES 28.5 billion for the nine months ended September 2025.",
    content: "Equity Group Holdings PLC has announced impressive financial results for the third quarter of 2025, with profit before tax rising 23% to KES 28.5 billion compared to KES 23.2 billion in the same period last year.\n\nThe Group's total assets grew by 18% to KES 1.4 trillion, while customer deposits increased by 15% to KES 1.1 trillion. The strong performance was driven by growth in both traditional banking and digital financial services.\n\nEquity Bank CEO James Mwangi attributed the results to the bank's focus on digital innovation and financial inclusion. The bank's mobile banking platform now serves over 16 million customers across the region.",
    category: "earnings",
    source: "NSE Market Updates",
    published_at: 2.days.ago
  },
  {
    security: Security.find_by(ticker: "KCB"),
    title: "KCB Group Declares Interim Dividend of KES 1.50 Per Share",
    summary: "KCB Group PLC Board declares interim dividend following strong half-year performance.",
    content: "The Board of Directors of KCB Group PLC has declared an interim dividend of KES 1.50 per ordinary share for the financial year ending December 31, 2025.\n\nThe dividend will be paid on November 30, 2025, to shareholders on the register as at the close of business on November 15, 2025. The shares will trade ex-dividend from November 13, 2025.\n\nThis dividend follows the Group's strong half-year results, which saw profit after tax increase by 18% to KES 22.3 billion.",
    category: "dividend",
    source: "KCB Group Press Release",
    published_at: 5.days.ago
  },
  {
    security: Security.find_by(ticker: "SCOM"),
    title: "Safaricom Launches 5G Services in Nairobi and Mombasa",
    summary: "Safaricom rolls out 5G network in major cities, promising faster internet speeds and enhanced connectivity.",
    content: "Safaricom PLC has officially launched its 5G network services in Nairobi and Mombasa, marking a significant milestone in Kenya's digital transformation journey.\n\nThe 5G network promises download speeds of up to 700 Mbps, significantly faster than the current 4G network. The rollout targets key business districts, residential areas, and major institutions.\n\nSafaricom CEO Peter Ndegwa stated that the 5G network will support emerging technologies such as IoT, smart cities, and autonomous vehicles. The company plans to expand 5G coverage to other major towns by mid-2026.",
    category: "corporate_action",
    source: "Safaricom PLC",
    published_at: 1.week.ago
  },
  {
    security: Security.find_by(ticker: "EABL"),
    title: "EABL Invests KES 5 Billion in New Brewery Expansion",
    summary: "East African Breweries announces major investment in production capacity expansion.",
    content: "East African Breweries Limited (EABL) has announced a KES 5 billion investment in expanding its brewing capacity across the region.\n\nThe investment will see the construction of a new state-of-the-art brewery in Kisumu and upgrades to existing facilities in Nairobi and Mombasa. The project is expected to create 2,000 direct jobs and thousands more in the supply chain.\n\nEABL Managing Director Jane Karuku said the expansion reflects the company's confidence in the region's economic growth and increasing consumer demand for premium beverages.",
    category: "corporate_action",
    source: "Business Daily",
    published_at: 10.days.ago
  },
  {
    security: Security.find_by(ticker: "NCBA"),
    title: "NCBA Bank Partners with Fintech Firms for Digital Lending",
    summary: "NCBA Bank announces strategic partnerships to enhance digital financial services.",
    content: "NCBA Bank has announced partnerships with leading fintech companies to expand its digital lending capabilities and improve customer experience.\n\nThe partnerships will enable the bank to leverage AI and machine learning for faster loan processing and better risk assessment. Customers will be able to access loans through mobile apps with approval times reduced from days to minutes.\n\nNCBA CEO John Gachora emphasized the bank's commitment to digital innovation and financial inclusion, particularly for SMEs and individual customers.",
    category: "corporate_action",
    source: "The Standard",
    published_at: 3.days.ago
  },
  {
    security: nil,
    title: "NSE Introduces New Trading Hours Starting January 2026",
    summary: "Nairobi Securities Exchange announces extended trading hours to improve market liquidity.",
    content: "The Nairobi Securities Exchange (NSE) has announced that it will extend its trading hours starting January 2, 2026. The new trading session will run from 8:00 AM to 4:00 PM EAT, an extension of one hour on each end.\n\nThe change is aimed at improving market liquidity and providing more flexibility for investors. The NSE believes the extended hours will attract more retail investors and align better with international market hours.\n\nThe Capital Markets Authority has approved the change, which will apply to all securities listed on the exchange.",
    category: "market_update",
    source: "NSE Press Release",
    published_at: 1.day.ago
  },
  {
    security: nil,
    title: "CMA Issues New Guidelines on ESG Reporting",
    summary: "Capital Markets Authority mandates ESG disclosures for all listed companies.",
    content: "The Capital Markets Authority (CMA) has issued new guidelines requiring all listed companies to include Environmental, Social, and Governance (ESG) disclosures in their annual reports starting from the 2026 financial year.\n\nThe guidelines aim to enhance transparency and encourage sustainable business practices among listed firms. Companies will be required to report on their carbon emissions, diversity policies, board composition, and community impact.\n\nCMA CEO Wycliffe Shamiah stated that the move aligns Kenya's capital markets with global best practices and will help attract ESG-focused investors.",
    category: "regulatory",
    source: "Capital Markets Authority",
    published_at: 4.days.ago
  }
]

news_data.each do |news|
  NewsItem.find_or_create_by!(title: news[:title]) do |item|
    item.security = news[:security]
    item.summary = news[:summary]
    item.content = news[:content]
    item.category = news[:category]
    item.source = news[:source]
    item.published_at = news[:published_at]
  end
end

puts "Created #{NewsItem.count} news items"

# Create sample alert rules
puts "Creating sample alert rules..."
alert_rules_data = [
  {
    user: trader_user,
    security: Security.find_by(ticker: "EQTY"),
    condition_type: "price",
    comparison_operator: "greater_than",
    threshold_value: 50.00,
    notification_method: "both",
    status: "active"
  },
  {
    user: trader_user,
    security: Security.find_by(ticker: "KCB"),
    condition_type: "price",
    comparison_operator: "less_than",
    threshold_value: 35.00,
    notification_method: "email",
    status: "active"
  },
  {
    user: trader_user,
    security: Security.find_by(ticker: "SCOM"),
    condition_type: "percent_change",
    comparison_operator: "greater_than",
    threshold_value: 5.0,
    notification_method: "in_app",
    status: "active"
  },
  {
    user: admin_user,
    security: Security.find_by(ticker: "EABL"),
    condition_type: "price",
    comparison_operator: "greater_than",
    threshold_value: 170.00,
    notification_method: "both",
    status: "active"
  },
  {
    user: admin_user,
    security: Security.find_by(ticker: "NCBA"),
    condition_type: "volume",
    comparison_operator: "greater_than",
    threshold_value: 50000,
    notification_method: "email",
    status: "inactive"
  }
]

alert_rules_data.each do |alert_data|
  next unless alert_data[:security] # Skip if security not found

  AlertRule.find_or_create_by!(
    user_id: alert_data[:user].id,
    security_id: alert_data[:security].id,
    condition_type: alert_data[:condition_type]
  ) do |alert|
    alert.comparison_operator = alert_data[:comparison_operator]
    alert.threshold_value = alert_data[:threshold_value]
    alert.notification_method = alert_data[:notification_method]
    alert.status = alert_data[:status]
  end
end

puts "Created #{AlertRule.count} alert rules"

puts "\n✅ Seeding complete!"
puts "  Admin: admin@terminal.com / password123"
puts "  Trader: trader@terminal.com / password123"
puts "\n📊 Demo portfolios created:"
puts "  Admin Portfolio: KES #{admin_portfolio.cash_balance}"
puts "  Trader Portfolio: KES #{trader_portfolio.cash_balance}"
puts "\n👁️  Demo watchlist created:"
puts "  #{trader_watchlist.name}: #{trader_watchlist.watchlist_items.count} securities"
puts "\n🔔 Demo alerts created:"
puts "  Total alert rules: #{AlertRule.count} (#{AlertRule.active.count} active)"
puts "\n💡 Run 'rake market_data:simulate_continuous' to start real-time simulation"
puts "💡 Run 'rake market_data:check_alerts' to manually check all alerts"
