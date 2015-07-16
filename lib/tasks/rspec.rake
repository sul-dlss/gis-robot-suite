begin
  require 'rspec/core/rake_task'

  namespace :spec do
    desc 'Run unit tests'
    RSpec::Core::RakeTask.new(:unit) do |t|
      t.pattern = 'spec/unit/**/*_spec.rb'
    end

    desc 'Run integration tests which requires GeoServer running'
    RSpec::Core::RakeTask.new(:integration) do |t|
      t.pattern = 'spec/integration/**/*_spec.rb'
    end
  end

  desc 'Run all tests'
  task :spec => [ 'spec:unit', 'spec:integration' ]
rescue LoadError
end
