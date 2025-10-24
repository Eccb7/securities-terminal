class CreateExchanges < ActiveRecord::Migration[8.0]
  def change
    create_table :exchanges do |t|
      t.string :code
      t.string :name
      t.string :timezone
      t.time :market_open
      t.time :market_close

      t.timestamps
    end
  end
end
