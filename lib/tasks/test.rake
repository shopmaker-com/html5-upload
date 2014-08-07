require 'rake/testtask'

task :default => [:'']

desc 'Run all tests'
task :'' do
  Rake::TestTask.new(:alltests) do |t|
    t.test_files = Dir.glob(File.join('spec', '**', '*_spec.rb'))
  end
  task(:alltests).execute
end

namespace :test do
  desc 'Run all tests with coverage'
  task :coverage do
    ENV['COVERAGE'] = 'true'
    Rake::Task[''].execute
  end
end
