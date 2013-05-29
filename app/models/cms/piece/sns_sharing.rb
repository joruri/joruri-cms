# encoding: utf-8
class Cms::Piece::SnsSharing < Cms::Piece
  
  before_save :set_link_types
  
  def in_link_types
    unless val = @in_link_types 
      @in_link_types = link_types_array
    end
    @in_link_types
  end
  
  def in_link_types=(values)
    @in_link_types = values.keys
  end
  
  def link_type_options
    [
      ["Twitter ツイート", "tweet"],
      ["Facebook いいね" , "fb_like"],
      ["Facebook 共有"   , "fb_share"],
      ["Google+ 共有"    , "gp_share"],
    ]
  end
  
  def link_types_array
    value = setting_value(:link_types)
    return [] if value.blank?
    return value.split(' ')
  end
    
  def link_types_hash
    labels = {}
    link_type_options.each {|v,k| labels[k] = v }
    hash   = {}
    link_types_array.each {|k| hash[k] = labels[k] if labels[k] }
    return hash
  end
  
  def set_link_types
    return true if in_link_types.nil?
    self.in_settings ||= {}
    self.in_settings[:link_types] = in_link_types.join(' ')
    return true
  end
end