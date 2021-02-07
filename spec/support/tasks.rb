require 'rake'

module TaskExampleGroup
  extend ActiveSupport::Concern

  included do
    let(:task_name) { self.class.top_level_description.sub(/\Arake /, '') }
    let(:tasks) { Rake::Task }

    subject(:task) { tasks[task_name] }
  end
end

RSpec.configure do |config|
  config.define_derived_metadata(file_path: %r{/spec/tasks/}) { |metadata| metadata[:type] = :task }

  config.include TaskExampleGroup, type: :task

  config.before(:suite) { Rails.application.load_tasks }
end
