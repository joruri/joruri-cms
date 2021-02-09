class CreateEnqueteAttachments < ActiveRecord::Migration
  def change
    create_table :enquete_attachments do |t|
      t.references  :site
      t.references  :answer_column
      t.string      :name
      t.text        :title
      t.text        :mime_type
      t.integer     :unid
      t.integer     :size
      t.integer     :image_is
      t.integer     :image_width
      t.integer     :image_height
      t.integer     :thumb_width
      t.integer     :thumb_height
      t.integer     :thumb_size
      t.timestamps null: false
    end
  end
end
