class CreateAlertRules < ActiveRecord::Migration[8.0]
  def change
    create_table :alert_rules do |t|
      t.string :name
      t.string :rule_type
      t.string :severity
      t.jsonb :expression
      t.boolean :enabled
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
