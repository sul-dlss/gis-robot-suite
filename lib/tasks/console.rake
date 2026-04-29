# frozen_string_literal: true

desc 'Run a console booted with robots'
task :console, :ROBOT_ENVIRONMENT do |_t, args|
  args.with_defaults(ROBOT_ENVIRONMENT: 'development')

  ENV['ROBOT_ENVIRONMENT'] ||= args[:ROBOT_ENVIRONMENT]
  Rake::Task['environment'].invoke

  require 'irb'

  ARGV.clear
  IRB.start
end
