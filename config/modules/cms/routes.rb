Joruri::Application.routes.draw do
  mod = "cms"
  
  match "/_preview/:site/(*path)" => "cms/admin/preview#index",
    :as => :cms_preview, :defaults => { :concept => nil }, :format => false
  
  ## -------------------------------------------------------
  ## admin
  
  scope "#{Joruri.admin_uri}/#{mod}", :module => mod, :as => mod do
    
    match "tool_rebuild" => "admin/tool/rebuild#index"
    match "tool_search"  => "admin/tool/search#index"
    match "tool_export"  => "admin/tool/export#index"
    match "tool_import"  => "admin/tool/import#index"
    
    match "tests_kana" => "admin/tests/kana#index",
      :as => :tests_kana
    match "embedded_file/:id/:name.:format" => "admin/embedded_files#index",
      :as => :embedded_file
    match "embedded_file/:id/thumb/:name.:format" => "admin/embedded_files#index",
      :as => :embedded_thumbnail, :thumbnail   => true
    
    resources :tool_link_checks,
      :controller  => "admin/tool/link_checks"
    resources :navi_sites,
      :controller  => "admin/navi/sites"
    resources :navi_concepts,
      :controller  => "admin/navi/concepts"
    resources :concepts,
      :controller => "admin/concepts",
      :path       => ":parent/concepts" do
        collection do
          get  :layouts
          post :layouts
        end
      end
    resources :sites,
      :controller => "admin/sites"
    resources :kana_dictionaries,
      :controller => "admin/kana_dictionaries" do
        collection do
          get :make
          post :make
          get :test
        end
      end
    resources :navi_concepts,
      :controller => "admin/navi/concepts"
    resources :emergencies,
      :controller => "admin/emergencies" do
        member do
          get :change
        end
    end
  end
  
  scope "#{Joruri.admin_uri}/#{mod}/c:concept", :module => mod, :as => mod do
    
    match "stylesheets/" => "admin/stylesheets#index",
      :as => :stylesheets, :format => false
    match "stylesheets/(*path)" => "admin/stylesheets#index",
      :as => :stylesheets, :format => false
    
    resources :contents,
      :controller => "admin/contents"
    resource :contents_rewrite,
      :controller  => "admin/content/rewrite"
    resources :nodes,
      :controller => "admin/nodes",
      :path       => ":parent/nodes" do
        collection do
          get :search
          get :content_options
          get :model_options
        end
      end
    resources :layouts,
      :controller => "admin/layouts"
    resources :pieces,
      :controller => "admin/pieces" do
        collection do
          get :content_options
          get :model_options
        end
      end
    resources :data_texts,
      :controller => "admin/data/texts"
    resources :data_files,
      :controller => "admin/data/files",
      :path       => ":parent/data_files" do
        member do
          get :download
          get :thumbnail
        end
      end
    resources :data_file_nodes,
      :controller => "admin/data/file_nodes",
      :path       => ":parent/data_file_nodes"
    resources :inline_data_files,
      :controller => "admin/inline/data_files",
      :path       => ":parent/inline_data_files" do
        member do
          get :download
          get :thumbnail
        end
      end
    resources :inline_data_file_nodes,
      :controller => "admin/inline/data_file_nodes",
      :path       => ":parent/inline_data_file_nodes"
    
    ## -----------------------------------------------------
    ## node
    
    resources :node_directories,
      :controller => "admin/node/directories",
      :path       => ":parent/node_directories"
    resources :node_pages,
      :controller => "admin/node/pages",
      :path       => ":parent/node_pages"
    resources :node_sitemaps,
      :controller => "admin/node/sitemaps",
      :path       => ":parent/node_sitemaps"
    
    ## -----------------------------------------------------
    ## piece
    
    resources :piece_frees,
      :controller => "admin/piece/frees"
    resources :piece_page_titles,
      :controller => "admin/piece/page_titles"
    resources :piece_bread_crumbs,
      :controller => "admin/piece/bread_crumbs"
    resources :piece_links,
      :controller => "admin/piece/links"
    resources :piece_link_items,
      :controller => "admin/piece/link_items",
      :path       => ":piece/piece_link_items"
    resources :piece_sns_sharings,
      :controller => "admin/piece/sns_sharings"
  end
  
  ## -------------------------------------------------------
  ## public
  
  scope "_public/#{mod}", :module => mod, :as => "" do
    
    match "node_preview/"  => "public/node/preview#index"
    match "node_pages/"    => "public/node/pages#index"
    match "node_sitemaps/" => "public/node/sitemaps#index"
  end
end