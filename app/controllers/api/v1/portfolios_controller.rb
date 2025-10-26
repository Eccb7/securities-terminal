class Api::V1::PortfoliosController < Api::V1::BaseController
  before_action :set_portfolio, only: [ :show, :update, :destroy ]

  def index
    @portfolios = policy_scope(Portfolio)
                    .includes(:positions)
                    .order(created_at: :desc)

    render json: {
      data: @portfolios.as_json(
        methods: [ :total_value, :total_cost, :total_profit_loss, :total_profit_loss_percentage ]
      )
    }
  end

  def show
    authorize @portfolio
    render json: {
      data: @portfolio.as_json(
        include: {
          positions: {
            include: {
              security: {
                only: [ :id, :symbol, :name, :security_type ],
                include: {
                  latest_quote: {
                    only: [ :last_price, :change, :change_percent, :updated_at ]
                  }
                }
              }
            },
            methods: [ :current_value, :profit_loss, :profit_loss_percentage ]
          }
        },
        methods: [ :total_value, :total_cost, :total_profit_loss, :total_profit_loss_percentage ]
      )
    }
  end

  def create
    @portfolio = current_user.portfolios.new(portfolio_params)
    authorize @portfolio

    if @portfolio.save
      render json: {
        data: @portfolio.as_json(
          methods: [ :total_value, :total_cost, :total_profit_loss, :total_profit_loss_percentage ]
        ),
        message: "Portfolio created successfully"
      }, status: :created
    else
      render json: {
        errors: @portfolio.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    authorize @portfolio

    if @portfolio.update(portfolio_params)
      render json: {
        data: @portfolio.as_json(
          methods: [ :total_value, :total_cost, :total_profit_loss, :total_profit_loss_percentage ]
        ),
        message: "Portfolio updated successfully"
      }
    else
      render json: {
        errors: @portfolio.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @portfolio

    if @portfolio.destroy
      render json: {
        message: "Portfolio deleted successfully"
      }
    else
      render json: {
        errors: @portfolio.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_portfolio
    @portfolio = Portfolio.find(params[:id])
  end

  def portfolio_params
    params.require(:portfolio).permit(
      :name,
      :description
    )
  end
end
