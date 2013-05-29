# encoding: utf-8
class EntityConversion::Log < ActiveRecord::Base
  include Sys::Model::Base
  
  validates_presence_of :content_id, :state, :env
  
  def status
    return nil if state.blank?
    state == "success" ? "成功" : "失敗"
  end
end