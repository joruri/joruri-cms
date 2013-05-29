Joruri::Application.routes.draw do
  mod = "bbs"
  
  ## -------------------------------------------------------
  ## admin
  
  scope "#{Joruri.admin_uri}/#{mod}/c:concept", :module => mod, :as => mod do
    
    resources :items,
      :controller => "admin/items",
      :path       => ":content/items"
    resources :responses,
      :controller => "admin/responses",
      :path       => ":content/:parent/responses"
    
    ## -----------------------------------------------------
    ## content
    
    resources :content_base,
      :controller => "admin/content/base"
    resources :content_settings,
      :controller => "admin/content/settings",
      :path       => ":content/content_settings"
    
    ## -----------------------------------------------------
    ## node
    
    resources :node_threads,
      :controller => "admin/node/threads",
      :path       => ":parent/node_threads"
    
    ## -----------------------------------------------------
    ## piece
    
    resources :piece_recent_items,
      :controller => "admin/piece/recent_items"
  end
  
  ## -------------------------------------------------------
  ## public
  
  scope "_public/#{mod}", :module => mod, :as => "" do
    
    match "node_threads/index.:format"         => "public/node/threads#index"
    match "node_threads/new.:format"           => "public/node/threads#new"
    match "node_threads/delete.:format"        => "public/node/threads#delete"
    match "node_threads/:thread/index.:format" => "public/node/threads#show"
  end
end
