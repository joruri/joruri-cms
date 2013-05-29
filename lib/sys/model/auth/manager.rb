# encoding: utf-8
module Sys::Model::Auth::Manager
  def readable
    self.and(0, 1) unless Core.user.has_auth?(:manager)
    return self
  end
  
  def editable
    self.and(0, 1) unless Core.user.has_auth?(:manager)
    return self
  end
  
  def creatable?
    return Core.user.has_auth?(:manager)
  end

  def readable?
    return Core.user.has_auth?(:manager)
  end

  def editable?
    return Core.user.has_auth?(:manager)
  end

  def deletable?
    return Core.user.has_auth?(:manager)
  end
end