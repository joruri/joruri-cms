# encoding: utf-8
module Enquete::Lib::EntityConversion
  
  def group_id_fields
    false
  end
  
  def text_fields
    {
      Enquete::Form       => true,
      Enquete::FormColumn => true,
    }
  end
end