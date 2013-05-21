# encoding: utf-8
module Calendar::Lib::EntityConversion
  
  def group_id_fields
    false
  end
  
  def text_fields
    {
      Calendar::Event => true,
    }
  end
end