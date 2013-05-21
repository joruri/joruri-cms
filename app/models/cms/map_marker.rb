# encoding: utf-8
class Cms::MapMarker < ActiveRecord::Base
  include Sys::Model::Base
  
  validates_presence_of :map_id, :lat, :lng
  
  def js_params
    name = self.name.gsub(/'/, "\\\\'").gsub(/\r\n|\r|\n/, "<br />")
    %Q(#{lat}, #{lng}, '#{name}')
  end
end
