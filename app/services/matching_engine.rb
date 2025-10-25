# MatchingEngine - Order matching and execution service
# Implements a simple price/time priority matching algorithm
#
# Usage:
#   MatchingEngine.submit_order(order)
#   MatchingEngine.match_orders(security)
#
class MatchingEngine
  class << self
    # Submit an order to the matching engine
    def submit_order(order)
      return unless order.valid?

      # Update order status to open
      order.update!(status: :open)

      # Try to match the order immediately
      match_orders(order.security, order)

      # Broadcast order update
      broadcast_order_update(order)

      order
    end

    # Match orders for a specific security
    # Implements price/time priority matching
    def match_orders(security, new_order = nil)
      # Get all open buy and sell orders for this security
      buy_orders = Order.where(security: security, side: :buy, status: [ :open, :partially_filled ])
                       .order(price: :desc, created_at: :asc)

      sell_orders = Order.where(security: security, side: :sell, status: [ :open, :partially_filled ])
                        .order(price: :asc, created_at: :asc)

      # Try to match orders
      buy_orders.each do |buy_order|
        break if buy_order.filled?

        sell_orders.each do |sell_order|
          break if buy_order.filled? || sell_order.filled?
          next if sell_order.filled?

          # Check if orders can be matched
          if can_match?(buy_order, sell_order)
            execute_trade(buy_order, sell_order)
          end
        end
      end
    end

    private

    # Check if two orders can be matched
    def can_match?(buy_order, sell_order)
      # Market orders can always be matched
      return true if buy_order.type_market? || sell_order.type_market?

      # For limit orders, buy price must be >= sell price
      return false if buy_order.price.nil? || sell_order.price.nil?

      buy_order.price >= sell_order.price
    end

    # Execute a trade between two orders
    def execute_trade(buy_order, sell_order)
      # Determine execution quantity (minimum of remaining quantities)
      execution_quantity = [ buy_order.remaining_quantity, sell_order.remaining_quantity ].min

      # Determine execution price (seller's limit price takes precedence)
      # In a real exchange, this would be more sophisticated
      execution_price = if sell_order.type_market?
        buy_order.price || buy_order.security.latest_quote&.ask || 0
      elsif buy_order.type_market?
        sell_order.price || sell_order.security.latest_quote&.bid || 0
      else
        # Take the earlier order's price (time priority)
        buy_order.created_at < sell_order.created_at ? buy_order.price : sell_order.price
      end

      return if execution_price <= 0

      # Update orders with fill information
      ActiveRecord::Base.transaction do
        # Update buy order
        update_order_fill(buy_order, execution_quantity, execution_price)

        # Update sell order
        update_order_fill(sell_order, execution_quantity, execution_price)

        # Create or update positions
        create_position(buy_order, execution_quantity, execution_price)
        reduce_position(sell_order, execution_quantity, execution_price)

        # Update portfolio values
        update_portfolio_value(buy_order.portfolio)
        update_portfolio_value(sell_order.portfolio)

        # Log the execution
        Rails.logger.info("Trade executed: #{execution_quantity} shares of #{buy_order.security.ticker} at KES #{execution_price}")

        # Broadcast updates
        broadcast_order_update(buy_order)
        broadcast_order_update(sell_order)
        broadcast_trade_execution(buy_order.security, execution_quantity, execution_price)
      end
    end

    # Update order with fill information
    def update_order_fill(order, quantity, price)
      new_filled_quantity = (order.filled_quantity || 0) + quantity
      total_value = ((order.filled_quantity || 0) * (order.average_fill_price || 0)) + (quantity * price)
      new_average_price = total_value / new_filled_quantity

      updates = {
        filled_quantity: new_filled_quantity,
        average_fill_price: new_average_price
      }

      # Update status based on fill percentage
      if new_filled_quantity >= order.quantity
        updates[:status] = :filled
        updates[:executed_at] = Time.current
      elsif new_filled_quantity > 0
        updates[:status] = :partially_filled
      end

      order.update!(updates)
    end

    # Create or update a position for a buy order
    def create_position(buy_order, quantity, price)
      return unless buy_order.portfolio

      position = Position.find_or_initialize_by(
        portfolio: buy_order.portfolio,
        security: buy_order.security
      )

      if position.persisted?
        # Update existing position
        total_quantity = position.quantity + quantity
        total_cost = (position.quantity * position.average_cost) + (quantity * price)
        new_average_cost = total_cost / total_quantity

        position.update!(
          quantity: total_quantity,
          average_cost: new_average_cost
        )
      else
        # Create new position
        position.update!(
          quantity: quantity,
          average_cost: price,
          current_price: price,
          market_value: quantity * price
        )
      end

      # Update current price and market value
      update_position_value(position)
    end

    # Reduce position for a sell order
    def reduce_position(sell_order, quantity, price)
      return unless sell_order.portfolio

      position = Position.find_by(
        portfolio: sell_order.portfolio,
        security: sell_order.security
      )

      return unless position

      new_quantity = position.quantity - quantity

      if new_quantity <= 0
        # Close the position
        position.destroy
      else
        # Reduce the position
        position.update!(quantity: new_quantity)
        update_position_value(position)
      end
    end

    # Update position's current price and market value
    def update_position_value(position)
      latest_quote = position.security.latest_quote
      return unless latest_quote

      position.update!(
        current_price: latest_quote.last_price,
        market_value: position.quantity * latest_quote.last_price
      )
    end

    # Update portfolio value and P&L
    def update_portfolio_value(portfolio)
      return unless portfolio

      total_market_value = portfolio.positions.sum(:market_value)
      total_cost = portfolio.positions.sum { |p| p.quantity * p.average_cost }
      unrealized_pl = total_market_value - total_cost

      portfolio.update!(
        total_value: total_market_value,
        unrealized_pl: unrealized_pl
      )
    end

    # Broadcast order update via Action Cable
    def broadcast_order_update(order)
      ActionCable.server.broadcast(
        "market_channel",
        {
          type: "order_update",
          order_id: order.id,
          status: order.status,
          filled_quantity: order.filled_quantity,
          fill_percentage: order.fill_percentage
        }
      )
    rescue => e
      Rails.logger.error("Failed to broadcast order update: #{e.message}")
    end

    # Broadcast trade execution
    def broadcast_trade_execution(security, quantity, price)
      ActionCable.server.broadcast(
        "market_channel",
        {
          type: "trade",
          ticker: security.ticker,
          quantity: quantity,
          price: price,
          timestamp: Time.current.to_i
        }
      )
    rescue => e
      Rails.logger.error("Failed to broadcast trade execution: #{e.message}")
    end
  end
end
