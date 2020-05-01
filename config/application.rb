require_relative 'boot'

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
Bundler.require(*Rails.groups)

module KattBNBApi
  class Application < Rails::Application
    config.load_defaults 5.2
    config.api_only = true
    config.i18n.available_locales = ['en-US', 'sv-SE']
    config.i18n.default_locale = (Rails.env == 'production') ? ('sv-SE') : ('en-US')
    config.active_job.queue_adapter = :delayed_job
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins Rails.env == 'production' ? ENV['CORS_ORIGIN'] : 'localhost:3000'
        resource '/api/v1/*', 
          headers: :any, 
          methods: %i[get post put patch delete],
          expose: %w(access-token expiry token-type uid client),
          max_age: 0
      end
    end
  end
end
