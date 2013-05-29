Joruri::Application.routes.draw do
  mod = "entity_conversion"
  
  ## -------------------------------------------------------
  ## admin
    
  scope "#{Joruri.admin_uri}/#{mod}/c:concept", :module => mod, :as => mod do
    
    resources :units,
      :controller => "admin/units",
      :path       => ":content/units"
    resources :new_units,
      :controller => "admin/new_units",
      :path       => ":content/new_units"
    resources :edit_units,
      :controller => "admin/edit_units",
      :path       => ":content/edit_units"
    resources :move_units,
      :controller => "admin/move_units",
      :path       => ":content/move_units"
    resources :end_units,
      :controller => "admin/end_units",
      :path       => ":content/end_units"
    resources :tests,
      :controller => "admin/tests",
      :path       => ":content/tests"
    resources :converts,
      :controller => "admin/converts",
      :path       => ":content/converts"
    
    ## -----------------------------------------------------
    ## content
    
    resources :content_base,
      :controller => "admin/content/base"
    resources :content_settings,
      :controller => "admin/content/settings",
      :path       => ":content/content_settings"
    
  end
end
