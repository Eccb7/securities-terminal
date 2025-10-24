class CreatePositions < ActiveRecord::Migration[8.0]
  def change
    create_table :positions do |t|
      t.references :portfolio, null: false, foreign_key: true
      t.references :security, null: false, foreign_key: true
      t.integer :quantity
      t.decimal :avg_price

      t.timestamps
    end
  end
end
