class UpdateAlertRulesForPriceAlerts < ActiveRecord::Migration[8.0]
  def up
    # Remove old columns that were for compliance alerts
    remove_column :alert_rules, :name if column_exists?(:alert_rules, :name)
    remove_column :alert_rules, :rule_type if column_exists?(:alert_rules, :rule_type)
    remove_column :alert_rules, :severity if column_exists?(:alert_rules, :severity)
    remove_column :alert_rules, :expression if column_exists?(:alert_rules, :expression)
    remove_column :alert_rules, :enabled if column_exists?(:alert_rules, :enabled)
    remove_column :alert_rules, :organization_id if column_exists?(:alert_rules, :organization_id)

    # Add new columns for price alerts
    add_reference :alert_rules, :user, null: false, foreign_key: true unless column_exists?(:alert_rules, :user_id)
    add_reference :alert_rules, :security, null: false, foreign_key: true unless column_exists?(:alert_rules, :security_id)
    add_column :alert_rules, :condition_type, :string, null: false unless column_exists?(:alert_rules, :condition_type)
    add_column :alert_rules, :comparison_operator, :string, null: false unless column_exists?(:alert_rules, :comparison_operator)
    add_column :alert_rules, :threshold_value, :decimal, precision: 15, scale: 2, null: false unless column_exists?(:alert_rules, :threshold_value)
    add_column :alert_rules, :notification_method, :string, default: "email" unless column_exists?(:alert_rules, :notification_method)
    add_column :alert_rules, :status, :string, default: "active" unless column_exists?(:alert_rules, :status)

    # Add indexes for efficient querying
    add_index :alert_rules, [ :user_id, :status ] unless index_exists?(:alert_rules, [ :user_id, :status ])
    add_index :alert_rules, [ :security_id, :status ] unless index_exists?(:alert_rules, [ :security_id, :status ])
  end

  def down
    # Remove new columns
    remove_index :alert_rules, [ :security_id, :status ] if index_exists?(:alert_rules, [ :security_id, :status ])
    remove_index :alert_rules, [ :user_id, :status ] if index_exists?(:alert_rules, [ :user_id, :status ])

    remove_column :alert_rules, :status if column_exists?(:alert_rules, :status)
    remove_column :alert_rules, :notification_method if column_exists?(:alert_rules, :notification_method)
    remove_column :alert_rules, :threshold_value if column_exists?(:alert_rules, :threshold_value)
    remove_column :alert_rules, :comparison_operator if column_exists?(:alert_rules, :comparison_operator)
    remove_column :alert_rules, :condition_type if column_exists?(:alert_rules, :condition_type)
    remove_column :alert_rules, :security_id if column_exists?(:alert_rules, :security_id)
    remove_column :alert_rules, :user_id if column_exists?(:alert_rules, :user_id)

    # Restore old columns
    add_reference :alert_rules, :organization, null: false, foreign_key: true unless column_exists?(:alert_rules, :organization_id)
    add_column :alert_rules, :enabled, :boolean unless column_exists?(:alert_rules, :enabled)
    add_column :alert_rules, :expression, :jsonb unless column_exists?(:alert_rules, :expression)
    add_column :alert_rules, :severity, :string unless column_exists?(:alert_rules, :severity)
    add_column :alert_rules, :rule_type, :string unless column_exists?(:alert_rules, :rule_type)
    add_column :alert_rules, :name, :string unless column_exists?(:alert_rules, :name)
  end
end
