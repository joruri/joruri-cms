# encoding: utf-8
class Cms::Map < ActiveRecord::Base
  include Sys::Model::Base
  
  has_many :markers_tmp, :foreign_key => 'map_id', :class_name => 'Cms::MapMarker',
    :dependent => :destroy

  def in_attributes
    map = {
      'title'    => title,
      'map_lat'  => map_lat,
      'map_lng'  => map_lng,
      'map_zoom' => map_zoom
    }
    map['markers'] = self.markers
    return map
  end
  
  def new_marker_format?
    if !point1_lat.blank? || !point2_lat.blank? || !point3_lat.blank? || !point4_lat.blank? || !point5_lat.blank?
      return false
    end
    return true
  rescue
    return true
  end
  
  def convert_to_new_marker_format
    return true if new_marker_format?
    1.upto(5) do |i|
      eval("self.point#{i}_name = nil")
      eval("self.point#{i}_lat  = nil")
      eval("self.point#{i}_lng  = nil")
    end
    self.save(:validate => false)
  end
  
  def markers
    if new_marker_format?
      return Cms::MapMarker.find(:all, :conditions => {:map_id => id}, :order => :sort_no)
    end
    
    newMarker = lambda do |i|
      Cms::MapMarker.new(
        :map_id => id,
        :name   => send("point#{i}_name"),
        :lat    => send("point#{i}_lat"),
        :lng    => send("point#{i}_lng")
      )
    end
    list = []
    1.upto(5) {|i| list << newMarker.call(i) if is_point(i) }
    return list
  end
  
  ## old version method
  def is_point(num)
    return false if self.send('point' + num.to_s + '_name').to_s ==''
    return false if self.send('point' + num.to_s + '_lat').to_s ==''
    return false if self.send('point' + num.to_s + '_lng').to_s ==''
    return true;
  end
end
