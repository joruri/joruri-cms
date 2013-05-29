# encoding: utf-8
module Cms::Model::Auth::Content
  def creatable?
    return false unless Core.user.has_auth?(:designer)
    return Core.user.has_priv?(:create, :item => content.concept)
  end
  
  def readable?
    return false unless Core.user.has_auth?(:designer)
    return Core.user.has_priv?(:read, :item => content.concept)
  end
  
  def editable?
    return false unless Core.user.has_auth?(:designer)
    return Core.user.has_priv?(:update, :item => content.concept)
  end

  def deletable?
    return false unless Core.user.has_auth?(:designer)
    return Core.user.has_priv?(:delete, :item => content.concept)
  end
end