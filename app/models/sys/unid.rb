# encoding: utf-8
class Sys::Unid < ActiveRecord::Base
  include Sys::Model::Base

  validates :model, :item_id, presence: true
end
