# Load the rails application
require File.expand_path('../application', __FILE__)

# If no database configuration exists, copy the default SQLite one over...
# unless FileTest.exists?('config/database.yml')
#   FileUtils.cp 'config/database.yml.example', 'config/database.yml'
# end

# Initialize the rails application
LibreTPV::Application.initialize!

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8
