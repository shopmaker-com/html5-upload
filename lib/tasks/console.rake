desc 'Load console'
task :console do
  puts 'Loading console...'
  system('irb -r ./app.rb')
end
