# encoding: utf-8
module Cms::Model::Rel::Map
  def self.included(mod)
    mod.has_many :maps, :primary_key => 'unid', :foreign_key => 'unid', :class_name => 'Cms::Map',
      :dependent => :destroy
      
    mod.after_save :save_maps
  end
  
  def in_maps
    unless val = @in_maps
      val = []
      maps.each {|map| val << map.in_attributes}
      @in_maps = val
    end
    @in_maps
  end

  def in_maps=(values)
    @maps = values
    @in_maps = @maps
  end
  
  def default_map_position
    "34.074598,134.551411" # tokushima
  end
  
  def find_map_by_name(name)
    return nil if maps.size == 0
    maps.each do |map|
      return map if map.name == name
    end
    return nil
  end
  
  def save_maps
    return true  unless @maps
    return false unless unid
    return false if @_sent_save_maps
    @_sent_save_maps = true
    
    @maps.each do |key, in_map|
      name = in_map[:name] || "1"
      map  = self.find_map_by_name(name) || Cms::Map.new({:unid => unid, :name => name})
      map.title       = in_map[:title]
      map.map_lat     = in_map[:map_lat]
      map.map_lng     = in_map[:map_lng]
      map.map_zoom    = in_map[:map_zoom]
      next unless map.save
      
      if in_map[:markers]
        markers = map.markers
        saved   = 0
        in_map[:markers].each do |key, in_marker|
          marker = markers[saved] || Cms::MapMarker.new(:map_id => map.id)
          marker.sort_no = saved
          marker.name = in_marker[:name]
          marker.lat  = in_marker[:lat]
          marker.lng  = in_marker[:lng]
          if !marker.changed? || marker.save
            saved += 1
          end
        end
        
        del_markers = markers.slice(saved, markers.size)
        del_markers.each do |m|
          m.destroy if map.new_marker_format?
        end if !del_markers.blank?
      end
      
      map.convert_to_new_marker_format
    end
    
    #maps(true)
    return true
  end
end