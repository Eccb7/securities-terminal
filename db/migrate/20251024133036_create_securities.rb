class CreateSecurities < ActiveRecord::Migration[8.0]
  def change
    create_table :securities do |t|
      t.string :ticker, null: false
      t.string :name, null: false
      t.string :instrument_type, null: false
      t.string :currency, default: 'KES'
      t.string :isin
      t.integer :lot_size, default: 1
      t.string :status, default: 'active'
      t.references :exchange, foreign_key: true

      t.timestamps
    end

    add_index :securities, :ticker, unique: true
    add_index :securities, :isin, unique: true, where: "isin IS NOT NULL"
    add_index :securities, :status
  end
end
