class UpdateAlertEventsForPriceAlerts < ActiveRecord::Migration[8.0]
  def change
    # Remove old columns
    remove_column :alert_events, :severity, :string if column_exists?(:alert_events, :severity)
    remove_column :alert_events, :payload, :jsonb if column_exists?(:alert_events, :payload)
    remove_column :alert_events, :resolved, :boolean if column_exists?(:alert_events, :resolved)

    # Add new columns for price alerts
    add_column :alert_events, :triggered_at, :datetime, null: false unless column_exists?(:alert_events, :triggered_at)
    add_column :alert_events, :actual_value, :decimal, precision: 15, scale: 2 unless column_exists?(:alert_events, :actual_value)
    add_column :alert_events, :status, :string, default: "pending" unless column_exists?(:alert_events, :status)

    # Add index for efficient querying
    add_index :alert_events, [ :alert_rule_id, :triggered_at ] unless index_exists?(:alert_events, [ :alert_rule_id, :triggered_at ])
    add_index :alert_events, :status unless index_exists?(:alert_events, :status)
  end
end
