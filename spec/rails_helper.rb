require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/bin/'
  add_filter '/config/'
  add_filter '/coverage/'
  add_filter '/db/'
  add_filter '/log/'
  add_filter '/public/'
  add_filter '/spec/'
  add_filter '/storage/'
  add_filter '/tmp/'
  add_filter '/vendor/'
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'support/tasks'
require 'action_cable/testing/rspec'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.before(type: :task) do
    output = StringIO.new
    $stdout = output
    @std_output = $stdout.string
  end
end
