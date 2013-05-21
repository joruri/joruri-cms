# encoding: utf-8
class Sys::UnidRelation < ActiveRecord::Base
  include Sys::Model::Base
  
  validates_presence_of :unid, :rel_unid, :rel_type
end
