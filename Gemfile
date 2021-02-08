source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '2.7.2'

gem 'rails', '~> 5.2.4.4'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 5.2'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'jbuilder', '~> 2.5'
gem 'rack-cors', require: 'rack/cors'
gem 'devise_token_auth', '~> 1.1', '>= 1.1.2'
gem 'active_model_serializers', '~> 0.10.10'
gem 'aws-sdk-s3'
gem 'rails-i18n', '~> 5.1'
gem 'devise-i18n', '~> 0.12.1'
gem 'newrelic_rpm'
gem 'icalendar'
gem 'delayed_job_active_record'
gem 'stripe', '~> 5.23', '>= 5.23.1'
gem 'prettier'

group :development, :test do
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'rspec-rails', '3.9.1'
  gem 'shoulda-matchers'
  gem 'factory_bot_rails'
  gem 'coveralls', require: false
  gem 'action-cable-testing'
  gem 'rspec-benchmark'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
