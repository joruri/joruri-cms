# encoding: utf-8
class Util::File::Lock
  attr_accessor :locked
  
  def initialize(names = [])
    @dir    = "#{Rails.root.to_s}/tmp/lock"
    @names  = names || []
    @locked = {}
  end
  
  def self.lock(name)
    lock = self.new
    lock.lock(name)
    return lock
  end
  
  def lock(name = nil)
    if name
      lock_by_name(name)
    else
      @names.each {|name| lock_by_name(name) }
    end
  end
  
  def lock_by_name(name)
    return false if @names.index(name)
    FileUtils.mkdir(@dir) unless ::File.exists?(@dir)
    
    fp = ::File.open("#{@dir}/_#{name}", 'w')
    return false unless fp
    return false unless fp.flock(File::LOCK_EX)
    
    @names << name
    @locked[name] = fp
    return self
  end
  
  def unlock(name = nil)
    if name
      unlock_by_name(name)
    else
      @names.each {|name| unlock_by_name(name) }
    end
  end
  
  def unlock_by_name(name)
    @locked[name].flock(File::LOCK_UN)
    @locked[name].close
    #::FileUtils.rm("#{@dir}/_#{name}")
    
    if rand(100) == 0
      Dir::glob("#{@dir}/_" + "#{name}".gsub(/^(.*_).*/, '\\1*')).each do |path|
        ::FileUtils.rm_f(path) if path != "#{@dir}/_#{name}"
      end
    end
    
    @names.delete(name)
    @locked.delete(name)
  end
end