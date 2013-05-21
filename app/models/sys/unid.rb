# encoding: utf-8
class Sys::Unid < ActiveRecord::Base
  include Sys::Model::Base
  
  validates_presence_of :model, :item_id
end
