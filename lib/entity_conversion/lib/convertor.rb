# encoding: utf-8
module EntityConversion::Lib::Convertor
  
  def self.factory(env, options = {})
    options[:env] = env
    
    if env == :test
      conv = EntityConversion::Lib::Convertor::Base.new(options)
      conv.extend(EntityConversion::Lib::Convertor::Test)
      return conv
    elsif env == :production
      conv = EntityConversion::Lib::Convertor::Base.new(options)
      conv.extend(EntityConversion::Lib::Convertor::Production)
      return conv
    end
    raise "Unknown conversion env"
  end
  
end