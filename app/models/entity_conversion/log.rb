# encoding: utf-8
class EntityConversion::Log < ActiveRecord::Base
  include Sys::Model::Base

  validates :content_id, :state, :env, presence: true

  def status
    return nil if state.blank?
    state == 'success' ? "成功" : "失敗"
  end
end
