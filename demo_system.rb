#!/usr/bin/env ruby
# Comprehensive demonstration of the Kenya Securities Terminal

puts "\n🇰🇪 KENYA SECURITIES TERMINAL - FEATURE DEMONSTRATION\n"
puts "=" * 70

# 1. Display System Overview
puts "\n📊 SYSTEM OVERVIEW"
puts "-" * 70
puts "Users: #{User.count}"
puts "Securities: #{Security.count}"
puts "Portfolios: #{Portfolio.count}"
puts "Watchlists: #{Watchlist.count}"
puts "News Items: #{NewsItem.count}"
puts "Alert Rules: #{AlertRule.count} (#{AlertRule.active.count} active)"
puts "Alert Events: #{AlertEvent.count}"

# 2. Display Securities with Latest Quotes
puts "\n📈 SECURITIES & LATEST QUOTES"
puts "-" * 70
Security.active.each do |security|
  quote = security.latest_quote
  if quote
    change = quote.price_change_percentage
    arrow = change >= 0 ? "▲" : "▼"
    color_code = change >= 0 ? "\e[32m" : "\e[31m"
    puts "#{security.ticker.ljust(6)} | KES #{quote.last_price.to_s.rjust(8)} | #{color_code}#{arrow} #{change.abs.round(2)}%\e[0m | Vol: #{quote.volume}"
  else
    puts "#{security.ticker.ljust(6)} | No quotes available"
  end
end

# 3. Display Portfolios
puts "\n💼 PORTFOLIOS"
puts "-" * 70
Portfolio.includes(:user, :positions).each do |portfolio|
  puts "#{portfolio.name} (#{portfolio.user.email})"
  puts "  Cash: KES #{portfolio.cash_balance}"
  puts "  Positions: #{portfolio.positions.count}"
  puts "  Total Value: KES #{portfolio.total_value || 'N/A'}"
  puts "  P&L: KES #{portfolio.unrealized_pl || '0.00'}"
  puts ""
end

# 4. Display Watchlists
puts "\n👁️  WATCHLISTS"
puts "-" * 70
Watchlist.includes(:user, :securities).each do |watchlist|
  puts "#{watchlist.name} (#{watchlist.user.email})"
  puts "  Securities: #{watchlist.securities.map(&:ticker).join(', ')}"
  puts ""
end

# 6. Display Alert Rules
puts "\n🔔 ALERT RULES"
puts "-" * 70
AlertRule.includes(:security, :user).order(created_at: :desc).each do |alert|
  status_icon = case alert.status
  when "active" then "✅"
  when "triggered" then "⚠️"
  else "⏸️"
  end

  latest_quote = alert.security.latest_quote
  current_price = latest_quote ? latest_quote.last_price : 0

  puts "#{status_icon} #{alert.security.ticker} | #{alert.condition_type} #{alert.comparison_operator.gsub('_', ' ')} KES #{alert.threshold_value}"
  puts "   Current: KES #{current_price} | User: #{alert.user.email} | Status: #{alert.status}"
end

# 7. Display Recent Alert Events
puts "\n⚡ RECENT ALERT EVENTS"
puts "-" * 70
recent_events = AlertEvent.includes(alert_rule: :security).order(triggered_at: :desc).limit(5)
if recent_events.any?
  recent_events.each do |event|
    time_ago = ((Time.current - event.triggered_at) / 60).round
    puts "#{event.alert_rule.security.ticker} | #{event.message}"
    puts "  Triggered: #{time_ago} minutes ago | Status: #{event.status}"
  end
else
  puts "No alert events yet"
end

# 8. Display Recent News
puts "\n📰 RECENT NEWS"
puts "-" * 70
NewsItem.includes(:security).order(published_at: :desc).limit(3).each do |news|
  security_tag = news.security ? "[#{news.security.ticker}]" : "[MARKET]"
  puts "#{security_tag} #{news.title}"
  puts "  #{news.summary[0..100]}..."
  puts "  Published: #{news.published_at.strftime('%Y-%m-%d')}"
  puts ""
end

# 9. Login Information
puts "\n🔐 LOGIN CREDENTIALS"
puts "-" * 70
puts "Admin User:"
puts "  Email: admin@terminal.com"
puts "  Password: password123"
puts "  Role: Super Admin"
puts ""
puts "Trader User:"
puts "  Email: trader@terminal.com"
puts "  Password: password123"
puts "  Role: Trader"

# 10. Usage Instructions
puts "\n🚀 QUICK START COMMANDS"
puts "-" * 70
puts "1. Start Rails Server:"
puts "   ~/.rvm/bin/rvm ruby-3.3.5 do bundle exec rails server"
puts ""
puts "2. Generate Market Data:"
puts "   ~/.rvm/bin/rvm ruby-3.3.5 do bundle exec rake market_data:simulate"
puts ""
puts "3. Check Alerts:"
puts "   ~/.rvm/bin/rvm ruby-3.3.5 do bundle exec rake market_data:check_alerts"
puts ""
puts "4. Continuous Simulation:"
puts "   ~/.rvm/bin/rvm ruby-3.3.5 do bundle exec rake market_data:simulate_continuous"
puts ""
puts "5. Match Orders:"
puts "   ~/.rvm/bin/rvm ruby-3.3.5 do bundle exec rake market_data:match_orders"

puts "\n" + "=" * 70
puts "✅ Kenya Securities Terminal Ready!"
puts "   Navigate to http://localhost:3000 to access the application"
puts "=" * 70 + "\n"
