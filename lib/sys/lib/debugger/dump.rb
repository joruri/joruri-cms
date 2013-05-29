# encoding: utf-8
## simple logger
class Sys::Lib::Debugger::Dump
  
  def self.dump_log(data)
    log = "#{Rails.root}/log/dump.log"
    f = ::File.open(log, 'a')
    #f.flock(File::LOCK_EX)
    f.puts to_str(data).force_encoding('utf-8')
    #f.flock(File::LOCK_UN)
    f.close
  end
  
  def self.sp(num)
    '  ' * num.to_i
  end
  
  def self.to_str(data, dep = 1)
    buf = ''
    if (data.class == Array)
      buf += 'Array ('
      data.each_with_index {|v,k| buf += "\n#{sp(dep)}#{k} => #{to_str(v, dep + 1)}" }
      buf += "\n#{sp(dep - 1)})"
    elsif (data.class == HashWithIndifferentAccess || data.class == Hash)
      buf += 'Hash ('
      data.each {|k,v| buf += "\n#{sp(dep)}#{k} => #{to_str(v, dep + 1)}" }
      buf += "\n#{sp(dep - 1)})"
    else
      buf += "#{data} <#{data.class}>"
    end
    return buf
  end
end
