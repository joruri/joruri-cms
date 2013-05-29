Joruri::Application.routes.draw do
  mod = "enquete"
  
  ## -------------------------------------------------------
  ## admin
  
  scope "#{Joruri.admin_uri}/#{mod}/c:concept", :module => mod, :as => mod do
    
    resources :forms,
      :controller => "admin/forms",
      :path       => ":content/forms"
    resources :form_columns,
      :controller => "admin/form_columns",
      :path       => ":content/:form/form_columns"
    resources :form_answers,
      :controller => "admin/form_answers",
      :path       => ":content/:form/form_answers"
    
    ## -----------------------------------------------------
    ## content
    
    resources :content_base,
      :controller => "admin/content/base"
    resources :content_settings,
      :controller => "admin/content/settings",
      :path       => ":content/content_settings"
    
    ## -----------------------------------------------------
    ## node
    
    resources :node_forms,
      :controller => "admin/node/forms",
      :path       => ":parent/node_forms"
    
    ## -----------------------------------------------------
    ## piece
    
  end
  
  ## -------------------------------------------------------
  ## public
  
  scope "_public/#{mod}", :module => mod, :as => "" do
    
    match "node_forms/index.:format"       => "public/node/forms#index"
    match "node_forms/:form/index.:format" => "public/node/forms#show"
    match "node_forms/:form/sent.:format"  => "public/node/forms#sent"
  end
end
