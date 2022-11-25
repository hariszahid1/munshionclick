# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "OrderItem.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
env :PATH, ENV['PATH']
env :GEM_PATH, ENV['GEM_PATH']
env :GEM_HOME, ENV['GEM_HOME']
set :output, {:error => 'log/error.log', :standard => 'log/cron.log'}

every '30 23 * * *' do
  puts "Stock Dump at 12:00 PM"
  rake 'db:stockcron'
end

every '40 23 * * *' do
  puts "DB Dump at 12:00 PM"
  rake 'db:backup'
end

every :day, at: '12:00am' do
  puts 'Send file test'
  rake 'db:filesend'
end
