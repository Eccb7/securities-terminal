class CreateAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :audit_logs do |t|
      t.references :actor, null: false, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.string :target_type
      t.integer :target_id
      t.jsonb :payload, default: {}

      t.timestamps
    end

    add_index :audit_logs, [ :target_type, :target_id ]
    add_index :audit_logs, :created_at
  end
end
