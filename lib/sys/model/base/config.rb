# encoding: utf-8
module Sys::Model::Base::Config
  def states
    [['有効','enabled'],['無効','disabled']]
  end
  
  def enabled
    self.and :state, 'enabled'
    self
  end

  def disabled
    self.and :state, 'disabled'
    self
  end
  
  def enabled?
    return state == 'enabled'
  end
  
  def disabled?
    return state == 'disabled'
  end
end