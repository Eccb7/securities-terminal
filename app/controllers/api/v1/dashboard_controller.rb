class Api::V1::DashboardController < Api::V1::BaseController
  skip_after_action :verify_policy_scoped, only: [ :index ]

  # GET /api/v1/dashboard
  def index
    user = current_user

    # Get user's portfolios
    portfolios = user.portfolios.includes(:positions)

    # Calculate total portfolio value and P&L
    total_portfolio_value = portfolios.sum { |p| p.total_value }.to_f
    total_unrealized_pl = portfolios.sum { |p| p.unrealized_pl }.to_f

    # Get orders stats
    active_orders_count = user.orders.where(status: [ "pending", "partial" ]).count
    pending_orders_count = user.orders.where(status: "pending").count

    # Get recent orders
    recent_orders = user.orders
                        .includes(:security)
                        .order(created_at: :desc)
                        .limit(5)
                        .map do |order|
      {
        id: order.id,
        security_symbol: order.security.symbol,
        order_type: order.order_type,
        quantity: order.quantity.to_i,
        price: order.price.to_f,
        status: order.status,
        created_at: order.created_at
      }
    end

    # Get market stats
    active_securities_count = Security.active.count
    exchanges_count = Exchange.count

    # Get top movers (securities with biggest price changes)
    top_movers = Security.active.limit(5).map do |security|
      quote = security.latest_quote
      next unless quote && quote.last_price && quote.open

      change_percent = ((quote.last_price - quote.open) / quote.open * 100).round(2)

      {
        id: security.id,
        symbol: security.ticker,
        name: security.name,
        latest_price: quote.last_price.to_f,
        change_percent: change_percent.to_f
      }
    end.compact

    # Get user's watchlists
    watchlists_count = user.watchlists.count
    watchlist_items_count = user.watchlists.sum { |w| w.watchlist_items.count }

    dashboard_data = {
      total_portfolio_value: total_portfolio_value,
      total_unrealized_pl: total_unrealized_pl,
      active_orders_count: active_orders_count,
      pending_orders_count: pending_orders_count,
      recent_orders: recent_orders,
      active_securities_count: active_securities_count,
      exchanges_count: exchanges_count,
      top_movers: top_movers,
      watchlists_count: watchlists_count,
      watchlist_items_count: watchlist_items_count
    }

    render_success(dashboard_data)
  end
end
