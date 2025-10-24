class CreateMarketQuotes < ActiveRecord::Migration[8.0]
  def change
    create_table :market_quotes do |t|
      t.references :security, null: false, foreign_key: true
      t.decimal :bid
      t.decimal :ask
      t.decimal :last_price
      t.bigint :volume
      t.decimal :high
      t.decimal :low
      t.decimal :open
      t.decimal :close
      t.datetime :timestamp

      t.timestamps
    end
  end
end
