class OrdersController < ApplicationController
  before_action :set_order, only: [ :show, :cancel, :modify ]

  def index
    @orders = policy_scope(Order)
                .includes(:security, :user)
                .for_user(current_user.id)
                .recent
                .page(params[:page])
                .per(25)

    # Apply filters
    @orders = @orders.where(status: params[:status]) if params[:status].present?
    @orders = @orders.where(side: params[:side]) if params[:side].present?
    @orders = @orders.for_security(params[:security_id]) if params[:security_id].present?
  end

  def show
    authorize @order
  end

  def new
    @order = Order.new
    @order.security_id = params[:security_id] if params[:security_id]
    authorize @order

    @securities = Security.active
  end

  def create
    @order = current_user.orders.build(order_params)
    authorize @order

    if @order.save
      # Submit order to matching engine (to be implemented)
      # MatchingEngine.submit_order(@order)

      redirect_to @order, notice: "Order created successfully"
    else
      @securities = Security.active
      render :new, status: :unprocessable_entity
    end
  end

  def cancel
    authorize @order

    if @order.cancel!
      respond_to do |format|
        format.html { redirect_to orders_path, notice: "Order cancelled successfully" }
        format.json { render json: { status: "cancelled", order_id: @order.id } }
      end
    else
      respond_to do |format|
        format.html { redirect_to @order, alert: "Unable to cancel order" }
        format.json { render json: { error: "Unable to cancel order" }, status: :unprocessable_entity }
      end
    end
  end

  def modify
    authorize @order

    unless @order.can_modify?
      redirect_to @order, alert: "Order cannot be modified in its current state"
      return
    end

    if @order.update(order_modify_params)
      redirect_to @order, notice: "Order modified successfully"
    else
      render :show, status: :unprocessable_entity
    end
  end

  def active
    skip_policy_scope
    @orders = current_user.orders.active.recent

    render json: {
      orders: @orders.map { |o| order_json(o) }
    }
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(
      :security_id,
      :side,
      :order_type,
      :quantity,
      :price,
      :stop_price,
      :time_in_force
    )
  end

  def order_modify_params
    params.require(:order).permit(:quantity, :price, :stop_price)
  end

  def order_json(order)
    {
      id: order.id,
      security: {
        id: order.security_id,
        ticker: order.security.ticker,
        name: order.security.name
      },
      side: order.side,
      order_type: order.order_type,
      quantity: order.quantity,
      price: order.price,
      filled_quantity: order.filled_quantity,
      remaining_quantity: order.remaining_quantity,
      status: order.status,
      time_in_force: order.time_in_force,
      created_at: order.created_at.iso8601,
      updated_at: order.updated_at.iso8601
    }
  end
end
