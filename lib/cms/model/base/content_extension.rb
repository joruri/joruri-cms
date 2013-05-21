class Cms::Model::Base::ContentExtension < Sys::Model::XmlRecord::Base
  def content
    @_record
  end
  
  def creatable?
    @_record.editable?
  end
  
  def editable?
    @_record.editable?
  end
  
  def deletable?
    @_record.editable?
  end
  
  def parse_xml
    
  end
end