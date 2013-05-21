# encoding: utf-8
class Cms::LinkCheck < ActiveRecord::Base
  include Sys::Model::Base
  
  validates_presence_of :link_uri
end
