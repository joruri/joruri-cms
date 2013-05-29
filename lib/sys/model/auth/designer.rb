# encoding: utf-8
module Sys::Model::Auth::Designer
  def readable
    self.and(0, 1) unless Core.user.has_auth?(:designer)
    return self
  end
  
  def editable
    self.and(0, 1) unless Core.user.has_auth?(:designer)
    return self
  end
  
  def creatable?
    return Core.user.has_auth?(:designer)
  end

  def readable?
    return Core.user.has_auth?(:designer)
  end

  def editable?
    return Core.user.has_auth?(:designer)
  end

  def deletable?
    return Core.user.has_auth?(:designer)
  end
end