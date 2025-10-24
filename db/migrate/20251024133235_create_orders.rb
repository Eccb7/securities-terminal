class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :security, null: false, foreign_key: true
      t.string :side
      t.string :order_type
      t.decimal :price
      t.integer :quantity
      t.integer :filled_quantity
      t.string :status
      t.datetime :placed_at
      t.datetime :executed_at

      t.timestamps
    end
  end
end
