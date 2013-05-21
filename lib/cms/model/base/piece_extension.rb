class Cms::Model::Base::PieceExtension < Sys::Model::XmlRecord::Base
  def piece
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
end