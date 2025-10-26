class Api::V1::NewsItemsController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    @news_items = NewsItem.published
                    .includes(:securities, :exchange)
                    .order(published_at: :desc)

    # Apply filters
    @news_items = @news_items.where(category: params[:category]) if params[:category].present?
    @news_items = @news_items.where(exchange_id: params[:exchange_id]) if params[:exchange_id].present?

    if params[:security_id].present?
      @news_items = @news_items.joins(:news_item_securities)
                      .where(news_item_securities: { security_id: params[:security_id] })
    end

    @news_items = @news_items.page(params[:page]).per(params[:per_page] || 25)

    render json: {
      data: @news_items.as_json(
        include: {
          securities: {
            only: [ :id, :symbol, :name ]
          },
          exchange: {
            only: [ :id, :name, :code ]
          }
        }
      ),
      meta: pagination_meta(@news_items)
    }
  end

  def show
    @news_item = NewsItem.published.find(params[:id])

    render json: {
      data: @news_item.as_json(
        include: {
          securities: {
            only: [ :id, :symbol, :name ],
            include: {
              latest_quote: {
                only: [ :last_price, :change, :change_percent ]
              }
            }
          },
          exchange: {
            only: [ :id, :name, :code ]
          }
        }
      )
    }
  end
end
