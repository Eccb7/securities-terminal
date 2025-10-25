class WatchlistsController < ApplicationController
  before_action :set_watchlist, only: [ :show, :edit, :update, :destroy ]

  def index
    @watchlists = policy_scope(Watchlist)
                    .includes(:user, watchlist_items: :security)
                    .where(user: current_user)
                    .order(created_at: :desc)
  end

  def show
    authorize @watchlist
    @watchlist_items = @watchlist.watchlist_items
                                  .includes(security: :market_quotes)
                                  .order("securities.ticker ASC")

    # Get all securities for the add security dropdown
    @available_securities = Security.active
                                    .where.not(id: @watchlist.securities.pluck(:id))
                                    .order(:ticker)
  end

  def new
    @watchlist = current_user.watchlists.build
    authorize @watchlist
  end

  def create
    @watchlist = current_user.watchlists.build(watchlist_params)
    authorize @watchlist

    if @watchlist.save
      redirect_to @watchlist, notice: "Watchlist created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @watchlist
  end

  def update
    authorize @watchlist

    if @watchlist.update(watchlist_params)
      redirect_to @watchlist, notice: "Watchlist updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @watchlist
    @watchlist.destroy
    redirect_to watchlists_path, notice: "Watchlist deleted successfully"
  end

  def add_security
    @watchlist = Watchlist.find(params[:id])
    authorize @watchlist

    security = Security.find(params[:security_id])

    if @watchlist.watchlist_items.exists?(security: security)
      redirect_to @watchlist, alert: "#{security.ticker} is already in this watchlist"
    else
      @watchlist.watchlist_items.create!(security: security)
      redirect_to @watchlist, notice: "#{security.ticker} added to watchlist"
    end
  end

  def remove_security
    @watchlist = Watchlist.find(params[:id])
    authorize @watchlist

    item = @watchlist.watchlist_items.find(params[:item_id])
    ticker = item.security.ticker
    item.destroy

    redirect_to @watchlist, notice: "#{ticker} removed from watchlist"
  end

  private

  def set_watchlist
    @watchlist = Watchlist.find(params[:id])
  end

  def watchlist_params
    params.require(:watchlist).permit(:name)
  end
end
