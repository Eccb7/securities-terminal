class CreateAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :audit_logs do |t|
      t.references :actor, null: false, foreign_key: true
      t.string :action
      t.string :target_type
      t.integer :target_id
      t.jsonb :payload

      t.timestamps
    end
  end
end
