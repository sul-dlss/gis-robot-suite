begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files = ['lib/**/*.rb', 'robots/**/*.rb']
    t.options = ['--readme', 'README.md', '-m', 'markdown']
  end

  namespace :yard do
    desc 'Clean up documentation'
    task :clean do
      FileUtils.rm_rf('doc')
    end
  end
rescue LoadError
  # ignore yard tasks
end
