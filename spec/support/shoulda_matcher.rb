Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure { |config| config.include(Shoulda::Matchers::ActiveRecord, type: :model) }
