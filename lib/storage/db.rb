# encoding: utf-8
module Storage::Db
  
  @@storage = Storage::File
  
  def self.storage(path, &block)
    r = @@storage.find(:first, :conditions => ["path = ?", path.to_s.gsub(/\/$/, '')])
    yield(r) if r && block_given?
    r
  end
  
  def self.find_records(path)
    @@storage.where(["path LIKE ?", path.to_s.gsub(/\/$/, '') + "/%"])
  end
  
  def self.entry_records(path)
    @@storage.where(["dirname = ?", path.to_s.gsub(/\/$/, '')])
  end
  
  def self.find(path)
    find_records(path).collect{|r| r.path}
  end
  
  def self.entries(path)
    entry_records(path).collect {|r| r.basename }
  end
  
  def self.exists?(path)
    storage(path) ? true : false
  end
   
  def self.directory?(path)
    storage(path) {|r| return r.directory }
  end
  
  def self.file?(path)
    storage(path) {|r| return !r.directory }
  end
  
  def self.mtime(path)
    storage(path) {|r| return r.updated_at }
  end
  
  def self.size(path)
    storage(path) {|r| return r.size }
  end
  
  # def self.mime_type(path)
  #   ::Storage::Db.mime_type(path)
  # end
  
  def self.mkdir(path)
    create_dir(path)
  end
  
  def self.mkdir_p(path)
    return true if exists?(path)
    
    created = false
    names   = []
    path.split("/").each do |p|
      names << p
      next if p.blank?
      
      current = names.join('/')
      if storage(current)
        created = false
      else
        create_dir(current)
        created = true
      end
    end
    return created
  end
  
  def self.mv(src, dst)
    r = storage(src)
    raise "No such file or directory - #{src}" unless r
    dst_dir = ::File.dirname(dst)
    raise "No such file or directory - #{dst_dir}" unless exists?(dst_dir)
    
    dst = ::File.join(dst, ::File.basename(src)) if directory?(dst)
    
    if file?(src)
      raise "File exists - #{dst}" if directory?(dst)
      rm_rf(dst)
      r.update_path(dst)
    else
      raise "File exists - #{dst}" if exists?(dst)
      r.update_path(dst)
      entry_records(src).each {|c| c.update_path(c.path.gsub(/#{Regexp.escape(src)}\//, "#{dst}/")) }
    end
    true
  end
  
  def self.cp(src, dst)
    r = storage(src)
    raise "No such file or directory - #{src}" unless r
    dst_dir = ::File.dirname(dst)
    raise "No such file or directory - #{dst_dir}" unless exists?(dst_dir)
    
    dst = ::File.join(dst, ::File.basename(src)) if directory?(dst)
    
    if file?(src)
      raise "File exists - #{dst}" if directory?(dst)
      rm_rf(dst)
      create_file(dst, r.data)
    else
      raise "File exists - #{dst}" if exists?(dst)
      r.dup.update_path(dst)
      entry_records(src).each {|c| c.dup.update_path(c.path.gsub(/#{Regexp.escape(src)}\//, "#{dst}/")) }
    end
    true
  end
  
  def self.rmdir(path)
    r = storage(path)
    return false unless r
    return false if entries(path).size > 0
    r.destroy
  end
   
  def self.rm_rf(path)
    find_records(path).each {|c| c.destroy } if directory?(path)
    storage(path) {|r| r.destroy }
    true
  end
   
  def self.touch(path)
    if r = storage(path)
      r.updated_at = Time.now
      return r.save
    end
    
    create_file(path)
  end
  
  def self.read(path)
    storage(path) {|r| return r.data.respond_to?(:force_encoding) ? r.data.force_encoding("utf-8") : r.data }
  end
  
  def self.binread(path)
    read(path)
  end
  
  def self.write(path, data)
    if r = storage(path)
      raise "Is a directory - #{path}" if directory?(path)
      return r.update_data(data)
    end
    create_file(path, data)
  end
  
  def self.binwrite(path, data)
    write(path, data)
  end
  
  def self.chmod(mode, path)
    true
  end

protected
  
  def self.create_dir(path)
    raise "File exists - #{path}" if exists?(path)
    
    dir = ::File.dirname(path)
    raise "No such file or directory - #{dir}" if dir != "/" && !storage(dir)
    
    @@storage.create_dir(path)
  end
  
  def self.create_file(path, data = "")
    raise "File exists - #{path}" if exists?(path)
    
    dir = ::File.dirname(path)
    raise "No such file or directory - #{dir}" if dir != "/" && !storage(dir)
    
    @@storage.create_file(path, data)
  end
  
end
