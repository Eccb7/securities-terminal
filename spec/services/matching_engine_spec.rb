# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MatchingEngine do
  describe '.match_orders' do
    let(:security) { create(:security) }
    let(:buyer) { create(:user, :trader) }
    let(:seller) { create(:user, :trader) }
    let(:buyer_portfolio) { create(:portfolio, user: buyer, cash_balance: 10000) }
    let(:seller_portfolio) { create(:portfolio, user: seller, cash_balance: 5000) }

    before do
      # Create a position for the seller
      Position.create!(
        portfolio: seller_portfolio,
        security: security,
        quantity: 100,
        average_cost: 40.0
      )
    end

    context 'with matching buy and sell orders' do
      let!(:buy_order) do
        create(:order,
          user: buyer,
          portfolio: buyer_portfolio,
          security: security,
          side: 'buy',
          order_type: 'limit',
          quantity: 50,
          price: 50.0,
          status: 'open'
        )
      end

      let!(:sell_order) do
        create(:order,
          user: seller,
          portfolio: seller_portfolio,
          security: security,
          side: 'sell',
          order_type: 'limit',
          quantity: 50,
          price: 48.0,
          status: 'open'
        )
      end

      it 'matches compatible orders' do
        described_class.match_orders(security)

        buy_order.reload
        sell_order.reload

        expect(buy_order.status).to eq('filled')
        expect(sell_order.status).to eq('filled')
        expect(buy_order.filled_quantity).to eq(50)
        expect(sell_order.filled_quantity).to eq(50)
      end

      it 'creates positions for buyer' do
        expect {
          described_class.match_orders(security)
        }.to change { buyer_portfolio.positions.count }.by(1)

        position = buyer_portfolio.positions.find_by(security: security)
        expect(position.quantity).to eq(50)
      end

      it 'updates seller position' do
        described_class.match_orders(security)

        position = seller_portfolio.positions.find_by(security: security)
        expect(position.quantity).to eq(50) # 100 - 50
      end

      it 'updates portfolio cash balances' do
        initial_buyer_cash = buyer_portfolio.cash_balance
        initial_seller_cash = seller_portfolio.cash_balance

        described_class.match_orders(security)

        buyer_portfolio.reload
        seller_portfolio.reload

        # Buyer pays execution price * quantity
        expect(buyer_portfolio.cash_balance).to be < initial_buyer_cash

        # Seller receives execution price * quantity
        expect(seller_portfolio.cash_balance).to be > initial_seller_cash
      end

      it 'creates audit logs for both users' do
        expect {
          described_class.match_orders(security)
        }.to change { AuditLog.count }.by_at_least(2)
      end
    end

    context 'with partial fills' do
      let!(:buy_order) do
        create(:order,
          user: buyer,
          portfolio: buyer_portfolio,
          security: security,
          side: 'buy',
          quantity: 100,
          price: 50.0,
          status: 'open'
        )
      end

      let!(:sell_order) do
        create(:order,
          user: seller,
          portfolio: seller_portfolio,
          security: security,
          side: 'sell',
          quantity: 30,
          price: 48.0,
          status: 'open'
        )
      end

      it 'partially fills the larger order' do
        described_class.match_orders(security)

        buy_order.reload
        sell_order.reload

        expect(buy_order.status).to eq('partially_filled')
        expect(buy_order.filled_quantity).to eq(30)
        expect(sell_order.status).to eq('filled')
        expect(sell_order.filled_quantity).to eq(30)
      end
    end

    context 'with non-matching prices' do
      let!(:buy_order) do
        create(:order,
          user: buyer,
          portfolio: buyer_portfolio,
          security: security,
          side: 'buy',
          quantity: 50,
          price: 45.0, # Lower than sell price
          status: 'open'
        )
      end

      let!(:sell_order) do
        create(:order,
          user: seller,
          portfolio: seller_portfolio,
          security: security,
          side: 'sell',
          quantity: 50,
          price: 50.0,
          status: 'open'
        )
      end

      it 'does not match orders with incompatible prices' do
        described_class.match_orders(security)

        buy_order.reload
        sell_order.reload

        expect(buy_order.status).to eq('open')
        expect(sell_order.status).to eq('open')
        expect(buy_order.filled_quantity).to eq(0)
        expect(sell_order.filled_quantity).to eq(0)
      end
    end

    context 'with insufficient cash' do
      let(:poor_buyer_portfolio) { create(:portfolio, user: buyer, cash_balance: 100) }

      let!(:buy_order) do
        create(:order,
          user: buyer,
          portfolio: poor_buyer_portfolio,
          security: security,
          side: 'buy',
          quantity: 100,
          price: 50.0,
          status: 'open'
        )
      end

      let!(:sell_order) do
        create(:order,
          user: seller,
          portfolio: seller_portfolio,
          security: security,
          side: 'sell',
          quantity: 100,
          price: 48.0,
          status: 'open'
        )
      end

      it 'rejects order due to insufficient funds' do
        described_class.match_orders(security)

        buy_order.reload
        expect(buy_order.status).to eq('rejected')
      end
    end
  end
end
