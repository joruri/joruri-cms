class AddFieldFormatToEnqueteFormColumns < ActiveRecord::Migration
  def change
    add_column :enquete_form_columns, :field_format, :string
  end
end
