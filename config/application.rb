require File.expand_path('../boot', __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# An API application comes with the following middleware by default:
# Rack::Sendfile
# ActionDispatch::Static
# ActionDispatch::LoadInterlock
# ActiveSupport::Cache::Strategy::LocalCache::Middleware
# Rack::Runtime
# ActionDispatch::RequestId
# Rails::Rack::Logger
# ActionDispatch::ShowExceptions
# ActionDispatch::DebugExceptions
# ActionDispatch::RemoteIp
# ActionDispatch::Reloader
# ActionDispatch::Callbacks
# Rack::Head
# Rack::ConditionalGet
# Rack::ETag

# Add Middleware
# config.middleware.use Rack::MethodOverride

# Removing Middleware:
# config.middleware.delete ::Rack::Sendfile

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RwAdapterCartodb
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '{**}')]

    # config.middleware.use Rack::Attack

    config.generators do |g|
      g.test_framework :rspec,
        fixtures: true,
        routing_specs: true,
        controller_specs: true,
        request_specs: true
    end
  end
end
