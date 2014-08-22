require 'bundler/setup'
require 'rake/testtask'
require 'bundler/gem_tasks'

Rake::TestTask.new do |t|
  t.pattern = "test/test_*.rb"
  t.verbose = true
end

task :default => :test

desc "Run benchmarks"
task :bench do
  load File.join(File.dirname(__FILE__), "benchmarks", "runner")
end

desc "Remove trailing whitespace"
task :whitespace do
  sh %{find . -name '*.rb' -exec sed -i '' 's/ *$//g' {} \\;}
end
