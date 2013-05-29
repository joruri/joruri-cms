# encoding: utf-8
class Article::Content::Doc < Cms::Content
  def rewrite_configs
    conf = []
    if node = doc_node
      line  = "RewriteRule ^#{node.public_uri}" + '((\d{4})(\d\d)(\d\d)(\d\d)(\d\d)(\d).*)'
      line += " #{public_path.gsub(/.*(\/_contents\/)/, '\\1')}/docs/$2/$3/$4/$5/$6/$1 [L]"
      conf << line
    end
    conf
  end
  
  def doc_node
    return @doc_node if @doc_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Article::Doc'
    @doc_node = item.find(:first, :order => :id)
  end
  
  def unit_node
    return @unit_node if @unit_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Article::Unit'
    @unit_node = item.find(:first, :order => :id)
  end
  
  def category_node
    return @category_node if @category_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Article::Category'
    @category_node = item.find(:first, :order => :id)
  end
  
  def attribute_node
    return @attribute_node if @attribute_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Article::Attribute'
    @attribute_node = item.find(:first, :order => :id)
  end
  
  def area_node
    return @area_node if @area_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Article::Area'
    @area_node = item.find(:first, :order => :id)
  end
  
  def recent_node
    return @recent_node if @recent_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Article::RecentDoc'
    @recent_node = item.find(:first, :order => :id)
  end
  
  def event_node
    return @event_node if @event_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Article::EventDoc'
    @event_node = item.find(:first, :order => :id)
  end
  
  def tag_node
    return @tag_node if @tag_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Article::TagDoc'
    @tag_node = item.find(:first, :order => :id)
  end
end