class Api::V1::OrdersController < Api::V1::BaseController
  before_action :set_order, only: [ :show, :update, :cancel, :modify ]

  def index
    @orders = policy_scope(Order)
                .includes(:security, :portfolio)
                .order(created_at: :desc)

    # Apply filters
    @orders = @orders.where(status: params[:status]) if params[:status].present?
    @orders = @orders.where(security_id: params[:security_id]) if params[:security_id].present?
    @orders = @orders.where(portfolio_id: params[:portfolio_id]) if params[:portfolio_id].present?

    @orders = @orders.page(params[:page]).per(params[:per_page] || 25)

    render json: {
      data: @orders.as_json(
        include: {
          security: { only: [ :id, :symbol, :name ] },
          portfolio: { only: [ :id, :name ] }
        },
        methods: [ :total_cost ]
      ),
      meta: pagination_meta(@orders)
    }
  end

  def show
    authorize @order
    render json: {
      data: @order.as_json(
        include: {
          security: { only: [ :id, :symbol, :name, :security_type ] },
          portfolio: { only: [ :id, :name ] },
          user: { only: [ :id, :email ] }
        },
        methods: [ :total_cost ]
      )
    }
  end

  def create
    @order = current_user.orders.new(order_params)
    authorize @order

    if @order.save
      render json: {
        data: @order.as_json(
          include: {
            security: { only: [ :id, :symbol, :name ] },
            portfolio: { only: [ :id, :name ] }
          },
          methods: [ :total_cost ]
        ),
        message: "Order created successfully"
      }, status: :created
    else
      render json: {
        errors: @order.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    authorize @order

    if @order.update(order_params)
      render json: {
        data: @order.as_json(
          include: {
            security: { only: [ :id, :symbol, :name ] },
            portfolio: { only: [ :id, :name ] }
          },
          methods: [ :total_cost ]
        ),
        message: "Order updated successfully"
      }
    else
      render json: {
        errors: @order.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @order

    if @order.destroy
      render json: {
        message: "Order deleted successfully"
      }
    else
      render json: {
        errors: @order.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def cancel
    authorize @order

    if @order.cancel!
      render json: {
        data: @order.reload.as_json(
          include: {
            security: { only: [ :id, :symbol, :name ] },
            portfolio: { only: [ :id, :name ] }
          },
          methods: [ :total_cost ]
        ),
        message: "Order cancelled successfully"
      }
    else
      render json: {
        errors: @order.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def modify
    authorize @order

    if @order.update(modify_params)
      render json: {
        data: @order.as_json(
          include: {
            security: { only: [ :id, :symbol, :name ] },
            portfolio: { only: [ :id, :name ] }
          },
          methods: [ :total_cost ]
        ),
        message: "Order modified successfully"
      }
    else
      render json: {
        errors: @order.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def active
    @orders = policy_scope(Order)
                .active
                .includes(:security, :portfolio)
                .order(created_at: :desc)

    render json: {
      data: @orders.as_json(
        include: {
          security: { only: [ :id, :symbol, :name ] },
          portfolio: { only: [ :id, :name ] }
        },
        methods: [ :total_cost ]
      )
    }
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(
      :security_id,
      :portfolio_id,
      :order_type,
      :side,
      :quantity,
      :price,
      :stop_price,
      :time_in_force,
      :notes
    )
  end

  def modify_params
    params.require(:order).permit(
      :quantity,
      :price,
      :stop_price,
      :time_in_force
    )
  end
end
