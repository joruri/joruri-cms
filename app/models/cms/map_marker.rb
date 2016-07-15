# encoding: utf-8
class Cms::MapMarker < ActiveRecord::Base
  include Sys::Model::Base

  validates :map_id, :lat, :lng, presence: true

  def js_params
    name = self.name.gsub(/'/, "\\\\'").gsub(/\r\n|\r|\n/, '<br />')
    %(#{lat}, #{lng}, '#{name}')
  end
end
