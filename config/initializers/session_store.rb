# Be sure to restart your server when you modify this file.

# cookie
Joruri::Application.config.session_store :cookie_store, key: '_joruri_session'

# or database
#Joruri::Application.config.session_store :active_record_store, key: '_joruri_session', :cookie_only => false
