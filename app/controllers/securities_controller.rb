class SecuritiesController < ApplicationController
  before_action :set_security, only: [ :show, :quote, :chart_data ]

  def index
    @securities = policy_scope(Security)
                    .includes(:exchange, :market_quotes)
                    .active

    # Apply filters
    @securities = @securities.by_instrument_type(params[:instrument_type]) if params[:instrument_type].present?
    @securities = @securities.by_exchange(params[:exchange_id]) if params[:exchange_id].present?
    @securities = @securities.search(params[:q]) if params[:q].present?

    # Paginate after filters
    @securities = @securities.page(params[:page]).per(25)

    @exchanges = Exchange.active
  end

  def show
    authorize @security
    @latest_quote = @security.latest_quote
    @recent_news = @security.news_items.recent.limit(10)
    @chart_data = fetch_chart_data(@security, params[:period] || "1d")
  end

  def quote
    authorize @security
    @quote = @security.latest_quote

    render json: {
      security: {
        id: @security.id,
        ticker: @security.ticker,
        name: @security.name,
        instrument_type: @security.instrument_type
      },
      quote: @quote ? quote_json(@quote) : nil
    }
  end

  def chart_data
    authorize @security
    period = params[:period] || "1d"
    data = fetch_chart_data(@security, period)

    render json: {
      security_id: @security.id,
      ticker: @security.ticker,
      period: period,
      data: data
    }
  end

  def search
    skip_authorization
    query = params[:q]

    @securities = Security.active
                          .search(query)
                          .limit(10)

    render json: {
      securities: @securities.map do |s|
        {
          id: s.id,
          ticker: s.ticker,
          name: s.name,
          instrument_type: s.instrument_type,
          exchange: s.exchange.code
        }
      end
    }
  end

  private

  def set_security
    @security = Security.find(params[:id])
  end

  def quote_json(quote)
    {
      last_price: quote.last_price,
      bid_price: quote.bid_price,
      ask_price: quote.ask_price,
      volume: quote.volume,
      open_price: quote.open_price,
      high_price: quote.high_price,
      low_price: quote.low_price,
      close_price: quote.close_price,
      price_change: quote.price_change,
      price_change_pct: quote.price_change_percentage,
      spread: quote.spread,
      mid_price: quote.mid_price,
      timestamp: quote.timestamp.iso8601
    }
  end

  def fetch_chart_data(security, period)
    case period
    when "1d"
      start_time = Time.current.beginning_of_day
      interval = 5.minutes
    when "1w"
      start_time = 1.week.ago
      interval = 1.hour
    when "1m"
      start_time = 1.month.ago
      interval = 1.day
    when "3m"
      start_time = 3.months.ago
      interval = 1.day
    when "1y"
      start_time = 1.year.ago
      interval = 1.week
    else
      start_time = Time.current.beginning_of_day
      interval = 5.minutes
    end

    quotes = security.market_quotes
                     .where("timestamp >= ?", start_time)
                     .order(:timestamp)

    # Group by interval and aggregate
    quotes.group_by { |q| (q.timestamp.to_i / interval).floor * interval }
          .map do |timestamp, group|
            {
              timestamp: Time.at(timestamp).iso8601,
              open: group.first.open_price || group.first.last_price,
              high: group.map(&:high_price).compact.max || group.map(&:last_price).compact.max,
              low: group.map(&:low_price).compact.min || group.map(&:last_price).compact.min,
              close: group.last.close_price || group.last.last_price,
              volume: group.sum(&:volume)
            }
          end
  end
end
