Joruri::Application.routes.draw do
  mod = "sys"
  
  ## -------------------------------------------------------
  ## script
  
  scope "_script/#{mod}", :module => mod, :as => mod do
    
    match "run/*path" => "script/runner#run", :format => false
  end
  
  ## -------------------------------------------------------
  ## admin
    
  scope "#{Joruri.admin_uri}/#{mod}", :module => mod, :as => mod do
    
    match "tests" => "admin/tests#index",
      :as => :tests
    match "tests_mail" => "admin/tests/mail#index",
      :as => :tests_mail
    match "tests_link_check" => "admin/tests/link_check#index",
      :as => :tests_link_check
    
    resource :my_account,
      :controller => "admin/my_account" do
        collection do
          get :edit_password
          put :update_password
        end
      end
    resources :settings,
      :controller  => "admin/settings"
    resources :maintenances,
      :controller => "admin/maintenances"
    resources :messages,
      :controller => "admin/messages"
    resources :languages,
      :controller => "admin/languages"
    resources :ldap_groups,
      :controller => "admin/ldap_groups",
      :path       => ":parent/ldap_groups"
    resources :ldap_users,
      :controller => "admin/ldap_users",
      :path       => ":parent/ldap_users"
    resources :ldap_synchros,
      :controller => "admin/ldap_synchros" do
        member do
          get  :synchronize
          post :synchronize
        end
      end
    resources :users,
      :controller => "admin/users"
    resources :groups,
      :controller => "admin/groups",
      :path       => ":parent/groups"
    resources :group_users,
      :controller => "admin/group_users",
      :path       => ":parent/group_users"
    resources :export_groups,
      :controller => "admin/groups/export" do
        collection do
          get  :export
          post :export
        end
      end
    resources :import_groups,
      :controller => "admin/groups/import" do
        collection do
          get  :import
          post :import
        end
      end
    resources :role_names,
      :controller => "admin/role_names"
    resources :object_privileges,
      :controller => "admin/object_privileges",
      :path       => ":parent/object_privileges"
    resources :operation_logs,
      :controller => "admin/operation_logs"
    resources :processes,
      :controller  => "admin/processes"
    resources :storage_files,
      :controller => "admin/storage_files",
      :path       => "storage_files(/*path)",
      :format     => false
  end
end
