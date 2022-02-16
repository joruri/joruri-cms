Joruri::Application.routes.draw do
  mod = "article"

  ## -------------------------------------------------------
  ## admin

  scope "#{Joruri.admin_uri}/#{mod}/c:concept", :module => mod, :as => mod do

    get ":content/doc_files/:parent/(*path)" => "admin/doc/files#preview",
      :as => :preview_doc_file
    get "rebuild" => "admin/rebuild#index",
      :path => ":content/rebuild", :format => false

    resources :units,
      :controller => "admin/units",
      :path       => ":content/:parent/units"
    resources :categories,
      :controller => "admin/categories",
      :path       => ":content/:parent/categories"
    resources :attributes,
      :controller => "admin/attributes",
      :path       => ":content/attributes"
    resources :areas,
      :controller => "admin/areas",
      :path       => ":content/:parent/areas"
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
    resources :published_docs,
      :controller => "admin/docs/published",
      :path       => ":content/published_docs"
    resources :all_docs,
      :controller => "admin/docs/all",
      :path       => ":content/all_docs"
    resources :related_docs,
      :controller => 'admin/related_docs', :only => [:show],
      :path       => ":content/related_docs"
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
    resources :node_event_docs,
      :controller => "admin/node/event_docs",
      :path       => ":parent/node_event_docs"
    resources :node_tag_docs,
      :controller => "admin/node/tag_docs",
      :path       => ":parent/node_tag_docs"
    resources :node_units,
      :controller => "admin/node/units",
      :path       => ":parent/node_units"
    resources :node_categories,
      :controller => "admin/node/categories",
      :path       => ":parent/node_categories"
    resources :node_attributes,
      :controller => "admin/node/attributes",
      :path       => ":parent/node_attributes"
    resources :node_areas,
      :controller => "admin/node/areas",
      :path       => ":parent/node_areas"

    ## -----------------------------------------------------
    ## piece

    resources :piece_recent_docs,
      :controller => "admin/piece/recent_docs"
    resources :piece_recent_tabs,
      :controller => "admin/piece/recent_tabs"
    resources :piece_recent_tab_tabs,
      :controller => "admin/piece/recent_tab/tabs",
      :path       => ":piece/piece_recent_tab_tabs"
    resources :piece_calendars,
      :controller => "admin/piece/calendars"
    resources :piece_units,
      :controller => "admin/piece/units"
    resources :piece_categories,
      :controller => "admin/piece/categories"
    resources :piece_attributes,
      :controller => "admin/piece/attributes"
    resources :piece_areas,
      :controller => "admin/piece/areas"

  end

  ## -------------------------------------------------------
  ## public

  scope "_public/#{mod}", :module => mod, :as => "" do

    get "node_docs/:name/index.html"                 => "public/node/docs#show"
    get "node_docs/:name/files/:type/:file.:format"  => "public/node/doc/files#show"
    get "node_docs/:name/files/:file.:format"        => "public/node/doc/files#show"
    get "node_docs/index.:format"                    => "public/node/docs#index"
    get "node_recent_docs/index.:format"             => "public/node/recent_docs#index"
    get "node_event_docs/schedule.:format"           => "public/node/event_docs#schedule"
    get "node_event_docs/:year/:month/index.:format" => "public/node/event_docs#month"
    get "node_event_docs/index.:format"              => "public/node/event_docs#month"
    get "node_tag_docs/index.:format"                => "public/node/tag_docs#index"
    post "node_tag_docs/index.:format"               => "public/node/tag_docs#index"
    get "node_tag_docs/:tag"                         => "public/node/tag_docs#index"
    get "node_units/:name/:attr/index.:format"       => "public/node/units#show_attr"
    get "node_units/:name/:file.:format"             => "public/node/units#show"
    get "node_units/index.html"                      => "public/node/units#index"
    get "node_categories/:name/:attr/index.:format"  => "public/node/categories#show_attr"
    get "node_categories/:name/:file.:format"        => "public/node/categories#show"
    get "node_categories/index.html"                 => "public/node/categories#index"
    get "node_attributes/:name/:attr/index.:format"  => "public/node/attributes#show_attr"
    get "node_attributes/:name/:file.:format"        => "public/node/attributes#show"
    get "node_attributes/index.html"                 => "public/node/attributes#index"
    get "node_areas/:name/:attr/index.:format"       => "public/node/areas#show_attr"
    get "node_areas/:name/:file.:format"             => "public/node/areas#show"
    get "node_areas/index.html"                      => "public/node/areas#index"
  end
end
