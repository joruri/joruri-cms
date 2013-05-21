# encoding: utf-8
module Sys::Model::Base::Page
  def states
    [['公開','public'],['非公開','closed']]
  end
  
  def public
    self.and "#{self.class.table_name}.state", 'public'
    self
  end
  
  def public?
    return state == 'public' && !published_at.blank?
  end
end