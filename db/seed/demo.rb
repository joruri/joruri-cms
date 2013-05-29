# encoding: utf-8

# encoding: utf-8

begin
  load "#{Rails.root}/db/seed/base.rb"
  load "#{Rails.root}/db/seed/demo/base.rb"
  puts "-- seed/demo success."
rescue => e
  puts "----------"
  puts e.to_s
  puts e.backtrace.join("\n")
end
