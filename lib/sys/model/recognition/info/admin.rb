# encoding: utf-8
class Sys::Model::Recognition::Info::Admin < Sys::Model::XmlRecord::Base
  set_model_name  "sys/recognition"
  set_node_xpath  "admin"
  set_column_name :info_xml
  set_primary_key :id
  attr_accessor   :recognized_at
  
  def recognition
    @_record
  end
  
  def creatable?
    true
  end
  
  def editable?
    true
  end
  
  def deletable?
    true
  end
  
  def parse_xml
    
  end
end