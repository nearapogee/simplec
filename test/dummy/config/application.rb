require_relative 'boot'

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
#require "action_cable/engine"
require "rails/test_unit/railtie"
require "sprockets/railtie"

Bundler.require(*Rails.groups)
require "simplec"

# Required in dummy application only
#
require 'bootstrap-sass'

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.generators do |g|
      g.javascript_engine :js
      g.assets false
      g.helper false
      g.skip_routes true
      g.orm :active_record, primary_key_type: :uuid,
        default: 'gen_random_uuid()' # rails doesn't apply this but should
    end

  end
end

