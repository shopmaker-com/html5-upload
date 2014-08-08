desc 'Load development console'
task :console do
  puts "Loading #{settings.environment} console..."
  system('irb -r ./app.rb')
end
