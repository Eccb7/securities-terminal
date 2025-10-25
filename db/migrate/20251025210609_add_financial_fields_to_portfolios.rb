class AddFinancialFieldsToPortfolios < ActiveRecord::Migration[8.0]
  def change
    add_column :portfolios, :total_value, :decimal, precision: 15, scale: 2, default: 0.0
    add_column :portfolios, :cash_balance, :decimal, precision: 15, scale: 2, default: 0.0
    add_column :portfolios, :unrealized_pl, :decimal, precision: 15, scale: 2, default: 0.0
    add_column :portfolios, :realized_pl, :decimal, precision: 15, scale: 2, default: 0.0
  end
end
