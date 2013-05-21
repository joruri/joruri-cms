# encoding: utf-8
module Faq::Lib::EntityConversion
  
  def group_id_fields
    false
  end
  
  def text_fields
    {
      Faq::Category => true,
      Faq::Doc      => true,
      Faq::Tag      => true,
    }
  end
end