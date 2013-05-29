Joruri::Application.routes.draw do
  mod = "faq"
  
  ## -------------------------------------------------------
  ## admin
  
  scope "#{Joruri.admin_uri}/#{mod}/c:concept", :module => mod, :as => mod do
    
    match ":content/doc_files/:parent/(*path)" => "admin/doc/files#preview",
      :as => :preview_doc_file
    match "rebuild" => "admin/rebuild#index",
      :path => ":content/rebuild", :format => false
    
    resources :categories,
      :controller => "admin/categories",
      :path       => ":content/:parent/categories"
    resources :docs,
      :controller => "admin/docs",
      :path       => ":content/docs"
    resources :edit_docs,
      :controller => "admin/docs/edit",
      :path       => ":content/edit_docs"
    resources :recognize_docs,
      :controller => "admin/docs/recognize",
      :path       => ":content/recognize_docs"
    resources :publish_docs,
      :controller => "admin/docs/publish",
      :path       => ":content/publish_docs"
    resources :all_docs,
      :controller => "admin/docs/all",
      :path       => ":content/all_docs"
    resources :inline_files,
      :controller => "admin/doc/files",
      :path       => ":content/doc/:parent/inline_files" do
        member do
          get :download
        end
      end
    
    ## -----------------------------------------------------
    ## content
    
    resources :content_base,
      :controller => "admin/content/base"
    resources :content_settings,
      :controller => "admin/content/settings",
      :path       => ":content/content_settings"
    
    ## -----------------------------------------------------
    ## node
    
    resources :node_docs,
      :controller => "admin/node/docs",
      :path       => ":parent/node_docs"
    resources :node_recent_docs,
      :controller => "admin/node/recent_docs",
      :path       => ":parent/node_recent_docs"
    resources :node_search_docs,
      :controller => "admin/node/search_docs",
      :path       => ":parent/node_search_docs"
    resources :node_tag_docs,
      :controller => "admin/node/tag_docs",
      :path       => ":parent/node_tag_docs"
    resources :node_categories,
      :controller => "admin/node/categories",
      :path       => ":parent/node_categories"
    
    ## -----------------------------------------------------
    ## piece
    
    resources :piece_recent_docs,
      :controller => "admin/piece/recent_docs"
    resources :piece_search_docs,
      :controller => "admin/piece/search_docs"
    resources :piece_categories,
      :controller => "admin/piece/categories"
  end

  ## -------------------------------------------------------
  ## public
  
  scope "_public/#{mod}", :module => mod, :as => "" do
    
    match "node_docs/:name/index.html"                => "public/node/docs#show"
    match "node_docs/:name/files/:type/:file.:format" => "public/node/doc/files#show"
    match "node_docs/:name/files/:file.:format"       => "public/node/doc/files#show"
    match "node_docs/index.:format"                   => "public/node/docs#index"
    match "node_recent_docs/index.:format"            => "public/node/recent_docs#index"
    match "node_search_docs/index.:format"            => "public/node/search_docs#index"
    match "node_tag_docs/index.:format"               => "public/node/tag_docs#index"
    match "node_tag_docs/:tag"                        => "public/node/tag_docs#index"
    match "node_categories/:name/:attr/index.:format" => "public/node/categories#show_attr"
    match "node_categories/:name/:file.:format"       => "public/node/categories#show"
    match "node_categories/index.html"                => "public/node/categories#index"
  end
end
