# encoding: utf-8
class Sys::UnidRelation < ActiveRecord::Base
  include Sys::Model::Base

  validates :unid, :rel_unid, :rel_type, presence: true
end
