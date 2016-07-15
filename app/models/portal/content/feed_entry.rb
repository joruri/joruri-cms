# encoding: utf-8
class Portal::Content::FeedEntry < Cms::Content
  def entry_node
    return @entry_node if @entry_node
    @doc_node = Cms::Node
                .published
                .where(content_id: id)
                .where(model: 'Portal::FeedEntry')
                .order(:id)
                .first
  end

  def category_node
    return @category_node if @category_node
    @category_node = Cms::Node
                     .published
                     .where(content_id: id)
                     .where(model: 'Portal::Category')
                     .order(:id)
                     .first
  end

  def event_node
    return @event_node if @event_node
    @event_node = Cms::Node
                  .published
                  .where(content_id: id)
                  .where(model: 'Portal::EventEntry')
                  .order(:id)
                  .first
  end

  def doc_node
    return @doc_node if @doc_node
    @doc_node = Cms::Node
                .published
                .where(content_id: id)
                .where(model: 'Article::Doc')
                .order(:id)
                .first
  end
end
