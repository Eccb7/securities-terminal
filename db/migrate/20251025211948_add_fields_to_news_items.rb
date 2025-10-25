class AddFieldsToNewsItems < ActiveRecord::Migration[8.0]
  def change
    add_column :news_items, :summary, :text
    add_column :news_items, :content, :text
    add_column :news_items, :category, :string
    add_column :news_items, :url, :string

    # Make security_id nullable (some news is general, not security-specific)
    change_column_null :news_items, :security_id, true
  end
end
