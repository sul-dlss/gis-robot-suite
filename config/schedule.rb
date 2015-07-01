# Use this file to easily define all of your cron jobs.

every 5.minutes do
  # cannot use :output with Hash/String because we don't want append behavior
  set :output, lambda { '> log/verify.log 2> log/cron.log' }
  set :environment_variable, 'ROBOT_ENVIRONMENT'
  rake 'robots:verify'
end

# Learn more: http://github.com/javan/whenever
