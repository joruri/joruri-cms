# encoding: utf-8
module Portal::DocHelper
  
  def doc_attr_css_class(entry)
    if entry.feed
      entry.categories_xml.to_s.scan(/<category [^>]*label=["']属性\/[^"']+["'][^>]*>/iu).each do |m|
        return nil if m !~ /term=/
        return "attr" + m.gsub(/.*term=["'](.*?)["'].*/, '\\1').gsub(/[^a-zA-Z0-9]/, '_').camelize
      end
      return nil
    elsif entry.doc
      if attr = entry.doc.attribute_items[0]
        return "attr" + attr.name.camelize
      end
    end
    return nil
  end
end
