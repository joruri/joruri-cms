# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Joruri::Application.initialize!

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# MultiDb https://github.com/schoefmax/multi_db
#MultiDb::ConnectionProxy.setup!
