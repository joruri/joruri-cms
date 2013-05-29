# encoding: utf-8
class Tourism::Piece::SearchMovie < Cms::Piece
  #validate :validate_settings
  
  def form_types
    [['プルダウン（標準）','select'],['ラジオボタン','radio']]
  end
  
  def setting_label(name)
    value = setting_value(name)
    case name
    when :form_type
      form_types.each {|c| return c[0] if c[1].to_s == value.to_s}
    end
    value
  end
end