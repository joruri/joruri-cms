# encoding: utf-8
class Util::File
  def self.put(path, options ={})
    if options[:mkdir] == true
      dir = ::File.dirname(path)
      FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)
    end
    if options[:data]
      f = ::File.open(path, 'w')
      f.flock(File::LOCK_EX)
      
      options[:data].force_encoding(Encoding::UTF_8) if options[:data].respond_to?(:force_encoding)
      
      f.write(options[:data] ? options[:data] : '')
      f.flock(File::LOCK_UN)
      f.close
   
    elsif options[:src]
      return false unless FileTest.exist?(options[:src])
      FileUtils.cp options[:src], path
    end
    return true
  end
end