class AddAttachmentConfigsToEnqueteFormColumn < ActiveRecord::Migration
  def change
    add_column :enquete_form_columns, :form_file_max_size, :integer
    add_column :enquete_form_columns, :form_file_extension, :string
  end
end
