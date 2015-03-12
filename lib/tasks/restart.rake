namespace :passenger do
  desc 'Restart Application'
  task :restart do
    FileUtils.touch 'tmp/restart.txt'
  end
end
