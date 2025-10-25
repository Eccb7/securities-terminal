class PortfoliosController < ApplicationController
  before_action :set_portfolio, only: [ :show, :edit, :update, :destroy ]

  def index
    @portfolios = policy_scope(Portfolio)
                    .includes(:user, :organization, positions: :security)
                    .page(params[:page])
                    .per(25)

    # Apply filters
    @portfolios = @portfolios.where(user_id: params[:user_id]) if params[:user_id].present?
    @portfolios = @portfolios.where(organization_id: params[:organization_id]) if params[:organization_id].present?
  end

  def show
    authorize @portfolio
    @positions = @portfolio.positions.includes(:security).order("securities.ticker ASC")
  end

  def new
    @portfolio = current_user.portfolios.build
    authorize @portfolio
  end

  def create
    @portfolio = current_user.portfolios.build(portfolio_params)
    @portfolio.organization = current_organization
    authorize @portfolio

    if @portfolio.save
      redirect_to @portfolio, notice: "Portfolio created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @portfolio
  end

  def update
    authorize @portfolio

    if @portfolio.update(portfolio_params)
      redirect_to @portfolio, notice: "Portfolio updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @portfolio

    if @portfolio.positions.exists?
      redirect_to @portfolio, alert: "Cannot delete portfolio with open positions"
    else
      @portfolio.destroy
      redirect_to portfolios_path, notice: "Portfolio deleted successfully"
    end
  end

  private

  def set_portfolio
    @portfolio = Portfolio.find(params[:id])
  end

  def portfolio_params
    params.require(:portfolio).permit(:name, :cash_balance)
  end

  def current_organization
    current_user.organization
  end
end
