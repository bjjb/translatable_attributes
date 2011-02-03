require 'bundler'
require 'rake/testtask'
require 'rake/rdoctask'

Bundler::GemHelper.install_tasks

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.pattern = "test/**/*_test.rb"
  t.verbose = false
end

Rake::RDocTask.new do |t|
  t.main = "README.md"
  t.rdoc_files.include "README.md", "lib/**/*.lib"
end

task :default => :test
