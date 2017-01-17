class AddGoogleMapApiKeyToCmsSites < ActiveRecord::Migration
  def up
    add_column :cms_sites, :google_map_api_key, :string
  end
  def down
    remove_column :cms_sites, :google_map_api_key
  end
end
