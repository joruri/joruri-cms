Joruri::Application.routes.draw do
  mod = "newsletter"

  ## -------------------------------------------------------
  ## admin
  
  scope "#{Joruri.admin_uri}/#{mod}/c:concept", :module => mod, :as => mod do
    
    resources :docs,
      :controller => "admin/docs",
      :path       => ":content/docs"
    resources :deliver_docs,
      :controller => "admin/deliver_docs",
      :path       => ":content/docs/:doc/deliver"
    resources :members,
      :controller => "admin/members",
      :path       => ":content/members"
    resources :testers,
      :controller => "admin/testers",
      :path       => ":content/testers"
    resources :requests,
      :controller => "admin/requests",
      :path       => ":content/requests"

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
    
    match "node_forms/index.:format"      => "public/node/forms#index"
    match "node_forms/sent.:format"       => "public/node/forms#sent"
    match "node_forms/change.:format"     => "public/node/forms#change"
    match "node_forms/subscribe/*email"   => "public/node/forms#subscribe", :format => false
    match "node_forms/unsubscribe/*email" => "public/node/forms#unsubscribe", :format => false
  end
end
