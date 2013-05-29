Joruri::Application.routes.draw do
  mod = "calendar"
  
  ## -------------------------------------------------------
  ## admin
  
  scope "#{Joruri.admin_uri}/#{mod}/c:concept", :module => mod, :as => mod do
    
    resources :events,
      :controller => "admin/events",
      :path       => ":content/events"
    
    ## -----------------------------------------------------
    ## content
    
    resources :content_base,
      :controller => "admin/content/base"
    resources :content_settings,
      :controller => "admin/content/settings",
      :path       => ":content/content_settings"
    
    ## -----------------------------------------------------
    ## node
    
    resources :node_events,
      :controller => "admin/node/events",
      :path       => ":parent/node_events"
    
    ## -----------------------------------------------------
    ## piece
    
    resources :piece_monthly_links,
      :controller => "admin/piece/monthly_links"
    resources :piece_daily_links,
      :controller => "admin/piece/daily_links"
  end
  
  ## -------------------------------------------------------
  ## public
  
  scope "_public/#{mod}", :module => mod, :as => "" do
    
    match "node_events/index.:format"              => "public/node/events#index"
    match "node_events/:year/index.:format"        => "public/node/events#index_yearly"
    match "node_events/:year/:month/index.:format" => "public/node/events#index_monthly"
  end
end
