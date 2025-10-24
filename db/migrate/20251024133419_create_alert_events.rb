class CreateAlertEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :alert_events do |t|
      t.references :alert_rule, null: false, foreign_key: true
      t.string :severity
      t.jsonb :payload
      t.boolean :resolved
      t.datetime :resolved_at
      t.text :message

      t.timestamps
    end
  end
end
