# encoding: utf-8
class Calendar::Content::Setting < Cms::ContentSetting
  set_config :doc_content_id, :name => "記事コンテンツ"
  
  def config_options
    case name
    when 'doc_content_id'
      contents = Core.site.contents.find(:all, :conditions => {:model => 'Article::Doc'})
      return contents.collect{|c| [c.name, c.id.to_s]}
    end
    super
  end
  
  def value_name
    if !value.blank?
      case name
      when 'doc_content_id'
        content = Cms::Content.find_by_id(value)
        return content.name if content
      end
    end
    super
  end
end