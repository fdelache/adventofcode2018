require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = 'test/*_test.rb'
  t.warning = false
end

task :default => [:run]

task :run do
	ruby "app.rb"
end