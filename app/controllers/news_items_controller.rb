class NewsItemsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]
  skip_after_action :verify_authorized, only: [ :index, :show ]

  def index
    @news_items = NewsItem.includes(:security)
                          .order(published_at: :desc)
                          .page(params[:page])
                          .per(20)

    # Apply filters
    @news_items = @news_items.where(security_id: params[:security_id]) if params[:security_id].present?
    @news_items = @news_items.where(category: params[:category]) if params[:category].present?

    # Search
    if params[:query].present?
      @news_items = @news_items.where("title LIKE ? OR content LIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
    end

    @securities = Security.active.order(:ticker)
  end

  def show
    @news_item = NewsItem.find(params[:id])
    @related_news = NewsItem.where(security: @news_item.security)
                            .where.not(id: @news_item.id)
                            .order(published_at: :desc)
                            .limit(5)
  end
end
