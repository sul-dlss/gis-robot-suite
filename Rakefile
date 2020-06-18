# frozen_string_literal: true

require 'rake'
require 'resque/pool/tasks'

# Import external rake tasks
Dir.glob('lib/tasks/*.rake').each { |r| import r }

desc 'Get application version'
task :app_version do
  puts File.read('VERSION')
end

desc 'Load complete environment into rake process'
task :environment do
  require_relative 'config/boot'
end

task 'resque:setup' => :environment

begin
  require 'rspec/core/rake_task'
  desc 'Run RSpec'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  desc 'Run RSpec'
  task :spec do
    abort 'Please install the rspec gem to run tests.'
  end
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  desc 'Run rubocop'
  task :rubocop do
    abort 'Please install the rubocop gem to run rubocop.'
  end
end

task :default => [:app_version, :spec, :rubocop]
