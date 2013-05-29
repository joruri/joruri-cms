# encoding: utf-8
module Sys::Model::Rel::Unid
  def self.included(mod)
    mod.has_one :unid_original, :primary_key => 'unid', :foreign_key => 'id', :class_name => 'Sys::Unid',
      :dependent => :destroy
    mod.validates_uniqueness_of :unid,
      :if => %Q(!unid.nil?)
    mod.after_save :save_unid
  end
  
  def unid_model_name
    self.class.to_s
  end
  
  def save_unid
    return false if @saved_unid
    return true if unid
    @saved_unid = true
    
    _unid   = Sys::Unid.new({ :item_id => id, :model => unid_model_name })
    return false unless _unid.save
    
    sql = "UPDATE #{self.class.table_name} SET unid = (#{_unid.id}) WHERE id = #{id}"
    self.class.connection.execute(sql)
    self.unid = _unid.id
  end
end
