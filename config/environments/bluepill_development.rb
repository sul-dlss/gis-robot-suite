WORKDIR=File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
robot_environment = ENV['ROBOT_ENVIRONMENT'] || 'development'
workflows = File.expand_path(File.join(WORKDIR, 'config', 'environments', "workflows_#{robot_environment}.rb"))
puts "Loading #{workflows}"
require workflows

Bluepill.application 'demo-bots',
  :log_file => "#{WORKDIR}/log/bluepill.log" do |app|
  app.working_dir = WORKDIR
  WORKFLOW_STEPS.each do |qualified_wf|
    wf = qualified_wf.gsub(/:/, '_')
    app.process(wf) do |process|
      # use configuration for number of workers -- default is 1
      n = WORKFLOW_N[qualified_wf] ? WORKFLOW_N[qualified_wf].to_i : 1
      puts "Creating #{n} worker#{n>1?'s':' '} for #{qualified_wf}"

      # queue order is *VERY* important
      #
      # XXX: make this configurable based on wf
      # WORKFLOW_PRIORITIES[wf] is the name of a second worker that reads the given queues
      #
      # see RobotMaster::Queue#queue_name for naming convention
      # @example
      #     queue_name('dor:assemblyWF:jp2-create')
      #     => 'dor_assemblyWF_jp2-create_default'
      #     queue_name('dor:assemblyWF:jp2-create', 100)
      #     => 'dor_assemblyWF_jp2-create_high'
      #
      queues = []
      %w{critical high default low}.each do |p|
        queues << "#{wf}_#{p}"
      end
      queues = queues.join(',')
      # puts "Using queues #{queues}"

      # use environment for these resque variables
      process.environment = {
        'QUEUES' => "#{queues}",
        'VERBOSE' => 'yes',
        'ROBOT_ENVIRONMENT' => robot_environment
      }

      # process configuration
      process.group = robot_environment
      process.stdout = process.stderr = "#{WORKDIR}/log/#{wf}.log"

      #process.pid_file = "#{WORKDIR}/run/#{wf}.pid"

      # spawn n worker processes
      if n > 1
        process.start_command = "env COUNT=#{n} rake workers" # not resque:workers
      else # 1 worker
        process.start_command = "rake environment resque:work"
      end
      # puts "Using #{process.start_command}"
      # puts "Using #{process.environment}"

      # we use bluepill to daemonize the resque workers rather than using
      # resque's BACKGROUND flag
      process.daemonize = true

      # graceful stops
      process.stop_grace_time = 60.seconds # must be greater than stop_signals total
      process.stop_signals = [
        :quit, 45.seconds, # waits for jobs, then exits gracefully
        :term, 10.seconds, # kills jobs and exits
        :kill              # no mercy
      ]

      # process monitoring

      # backoff if process is flapping between states
      # process.checks :flapping,
      #                :times => 2, :within => 30.seconds,
      #                :retry_in => 7.seconds

      # restart if process runs for longer than 15 mins of CPU time
      # process.checks :running_time,
      #                :every => 5.minutes, :below => 15.minutes

      # restart if CPU usage > 75% for 3 times, check every 10 seconds
      # process.checks :cpu_usage,
      #                :every => 10.seconds,
      #                :below => 75, :times => 3,
      #                :include_children => true
      #
      # restart the process or any of its children
      # if MEM usage > 100MB for 3 times, check every 10 seconds
      # process.checks :mem_usage,
      #                :every => 10.seconds,
      #                :below => 100.megabytes, :times => 3,
      #                :include_children => true

      # NOTE: there is an implicit process.keepalive
    end
  end
end
