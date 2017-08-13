# Very noisy circular warning in dummy application only
#
# 'dragonfly' is required again in dragonfly/middleware.
#
silence_warnings do
  require 'dragonfly'
end

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  secret "3c7b6da51ad204e7c4b4d766754cf46fec0ed3e79487d823112d942ee3e0865b"

  url_format "/media/:job/:name"

  datastore :file,
    root_path: Rails.root.join('public/system/dragonfly', Rails.env),
    server_root: Rails.root.join('public')
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end
