# encoding: utf-8
class Cms::NodeSetting < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :node, :foreign_key => :node_id, :class_name => 'Cms::Node'

  validates_presence_of :node_id, :name
end
