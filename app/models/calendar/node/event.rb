# encoding: utf-8
class Calendar::Node::Event < Cms::Node
  #validate :validate_settings
  
  def list_types
    [['日別一覧（標準）','each_date'],['イベント別一覧','each_event']]
  end
  
  def setting_label(name)
    value = setting_value(name)
    case name
    when :list_type
      list_types.each {|c| return c[0] if c[1].to_s == value.to_s}
    end
    value
  end
  
  # def validate_settings
  # end
end