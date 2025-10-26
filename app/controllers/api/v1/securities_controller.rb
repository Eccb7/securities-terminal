class Api::V1::SecuritiesController < Api::V1::BaseController
  before_action :set_security, only: [ :show, :quote, :chart_data ]

  # GET /api/v1/securities
  def index
    @securities = policy_scope(Security)
                    .includes(:exchange, :latest_quote)
                    .active

    # Apply filters
    @securities = @securities.where(exchange_id: params[:exchange]) if params[:exchange].present?
    @securities = @securities.where(security_type: params[:security_type]) if params[:security_type].present?

    # Search by symbol or name
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @securities = @securities.where(
        "LOWER(symbol) LIKE LOWER(?) OR LOWER(name) LIKE LOWER(?)",
        search_term,
        search_term
      )
    end

    # Pagination
    page = params[:page] || 1
    per_page = params[:per_page] || 25
    @securities = @securities.page(page).per(per_page)

    render_success(
      @securities.as_json(include: { exchange: { only: [ :id, :code, :name ] }, latest_quote: {} }),
      meta: pagination_meta(@securities)
    )
  end

  # GET /api/v1/securities/:id
  def show
    authorize @security

    render_success(
      @security.as_json(
        include: {
          exchange: { only: [ :id, :code, :name, :country, :currency ] },
          latest_quote: {}
        }
      )
    )
  end

  # GET /api/v1/securities/:id/quote
  def quote
    authorize @security

    # Get the latest quote for this security
    latest_quote = @security.market_quotes.order(timestamp: :desc).first

    if latest_quote
      render_success(latest_quote.as_json)
    else
      render_error("No quote data available", status: :not_found)
    end
  end

  # GET /api/v1/securities/:id/chart_data
  def chart_data
    authorize @security

    # Get historical quotes for charting
    period = params[:period] || "1d" # 1d, 1w, 1m, 3m, 1y

    start_date = case period
    when "1d" then 1.day.ago
    when "1w" then 1.week.ago
    when "1m" then 1.month.ago
    when "3m" then 3.months.ago
    when "1y" then 1.year.ago
    else 1.day.ago
    end

    quotes = @security.market_quotes
                     .where("timestamp >= ?", start_date)
                     .order(timestamp: :asc)
                     .select(:timestamp, :open_price, :high_price, :low_price, :last_price, :volume)

    render_success(quotes.as_json)
  end

  # GET /api/v1/securities/search
  def search
    query = params[:q] || params[:query]

    if query.blank?
      return render_error("Search query is required", status: :bad_request)
    end

    @securities = policy_scope(Security)
                    .active
                    .where(
                      "LOWER(symbol) LIKE LOWER(?) OR LOWER(name) LIKE LOWER(?)",
                      "%#{query}%",
                      "%#{query}%"
                    )
                    .limit(10)

    render_success(@securities.as_json(only: [ :id, :symbol, :name, :security_type ]))
  end

  private

  def set_security
    @security = Security.includes(:exchange, :latest_quote).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error("Security not found", status: :not_found)
  end
end
