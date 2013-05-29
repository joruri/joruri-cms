# encoding: utf-8
module Sys::Model::Auth::Free
  def readable
    return self
  end
  
  def editable
    return self
  end
  
  def creatable?
    true
  end

  def readable?
    true
  end

  def editable?
    true
  end

  def deletable?
    true
  end
end