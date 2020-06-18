# frozen_string_literal: true

desc 'Run a console booted with robots'
task :console, :ROBOT_ENVIRONMENT do |_t, args|
  args.with_defaults(ROBOT_ENVIRONMENT: 'development')

  ENV['ROBOT_ENVIRONMENT'] ||= args[:ROBOT_ENVIRONMENT]
  Rake::Task['environment'].invoke

  begin
    require 'pry'
    IRB = Pry
  rescue LoadError
    require 'irb'
  end

  ARGV.clear
  IRB.start
end
