# encoding: utf-8
class Sys::Task < ActiveRecord::Base
  include Sys::Model::Base
  
  has_one :unid_data, :primary_key => :unid, :foreign_key => :id, :class_name => 'Sys::Unid'
end
