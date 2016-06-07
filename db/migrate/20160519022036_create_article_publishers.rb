class CreateArticlePublishers < ActiveRecord::Migration
  def self.up
    create_table :article_publishers do |t|
      t.integer :item_id
      t.integer :content_id
      t.string :item_model

      t.timestamps
    end
    add_index :article_publishers, :item_model
  end

  def self.down
    drop_table :article_publishers
  end
end
