class Util::Config
  @@cache = {}
  
  def self.load(filename, options = {})
    filename = filename.to_s
    
    if !@@cache[filename]
      file = "#{Rails.root}/config/#{filename}.yml"
      @@cache[filename] = YAML.load_file(file)
    end
    
    section = options[:section]
    if section == false
      return @@cache[filename]
    elsif section
      return @@cache[filename][section]
    else
      return @@cache[filename][Rails.env]
    end
  end
end
