class CreateNewsItems < ActiveRecord::Migration[8.0]
  def change
    create_table :news_items do |t|
      t.string :title
      t.text :body
      t.string :source
      t.datetime :published_at
      t.references :security, null: false, foreign_key: true
      t.jsonb :tags

      t.timestamps
    end
  end
end
