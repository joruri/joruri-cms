# encoding: utf-8

# encoding: utf-8

begin
  load "#{Rails.root}/db/seed/test/base.rb"
  puts "-- seed/test success."
rescue => e
  puts e.to_s
  puts e.backtrace.join("\n")
end
