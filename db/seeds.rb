# encoding: utf-8

begin
  load "#{Rails.root}/db/seed/base.rb"
rescue => e
  puts "----------"
  puts e.to_s
  puts e.backtrace.join("\n")
end
