# encoding: utf-8
module Cms::Model::Auth::Concept
  def readable
    if Core.site
      self.and :site_id, Core.site.id
    else
      self.and :site_id, 'IS', nil
    end
    
    if Core.concept
      self.and(0, 1) unless Core.user.has_priv?(:read, :item => Core.concept)
      self.and :concept_id, Core.concept.id
    else
      self.and :concept_id, 'IS', nil
    end
    return self
  end
  
  def creatable?
    return false unless Core.user.has_auth?(:designer)
    return Core.user.has_priv?(:create, :item => concept(true))
  end
  
  def readable?
    return false unless Core.user.has_auth?(:designer)
    return Core.user.has_priv?(:read, :item => concept(true))
  end
  
  def editable?
    return false unless Core.user.has_auth?(:designer)
    return Core.user.has_priv?(:update, :item => concept(true))
  end

  def deletable?
    return false unless Core.user.has_auth?(:designer)
    return Core.user.has_priv?(:delete, :item => concept(true))
  end
end