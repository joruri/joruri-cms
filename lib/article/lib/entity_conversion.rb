# encoding: utf-8
module Article::Lib::EntityConversion
  
  def group_id_fields
    false
  end
  
  def text_fields
    {
      Article::Area      => true,
      Article::Attribute => true,
      Article::Category  => true,
      Article::Doc       => true,
      Article::Tag       => true,
    }
  end
end