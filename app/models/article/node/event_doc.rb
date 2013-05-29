# encoding: utf-8
class Article::Node::EventDoc < Cms::Node
  #validate :validate_settings
  
  def list_types
    [['タイトル一覧（標準）','titles'],['ブログ形式','blog']]
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