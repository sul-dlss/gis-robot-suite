require 'yard'

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb', 'robots/**/*.rb']
  t.options = ['--readme', 'README.md', '-m', 'markdown'] # optional
end