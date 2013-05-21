# encoding: utf-8
class Portal::Content::FeedEntry < Cms::Content

  def entry_node
    return @entry_node if @entry_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Portal::FeedEntry'
    @doc_node = item.find(:first, :order => :id)
  end

  def category_node
    return @category_node if @category_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Portal::Category'
    @category_node = item.find(:first, :order => :id)
  end

  def event_node
    return @event_node if @event_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Portal::EventEntry'
    @event_node = item.find(:first, :order => :id)
  end

  def doc_node
    return @doc_node if @doc_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Article::Doc'
    @doc_node = item.find(:first, :order => :id)
  end
end