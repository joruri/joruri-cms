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
    @dc_node = Cms::Node
               .published
               .where(content_id: id)
               .where(model: 'Article::Doc')
               .order(:id)
               .first
  end

  def unit_node
    return @unit_node if @unit_node
    @unit_node = Cms::Node
                 .published
                 .where(content_id: id)
                 .where(model: 'Article::Unit')
                 .order(:id)
                 .first
  end

  def category_node
    return @category_node if @category_node
    @category_node = Cms::Node
                     .published
                     .where(content_id: id)
                     .where(model: 'Article::Category')
                     .order(:id)
                     .first
  end

  def attribute_node
    return @attribute_node if @attribute_node
    @attribute_node = Cms::Node
                      .published
                      .where(content_id: id)
                      .where(model: 'Article::Attribute')
                      .order(:id)
                      .first
  end

  def area_node
    return @area_node if @area_node
    @area_node = Cms::Node
                 .published
                 .where(content_id: id)
                 .where(model: 'Article::Area')
                 .order(:id)
                 .first
  end

  def recent_node
    return @recent_node if @recent_node
    @recent_node = Cms::Node
                   .published
                   .where(content_id: id)
                   .where(model: 'Article::RecentDoc')
                   .order(:id)
                   .first
  end

  def event_node
    return @event_node if @event_node
    @event_node = Cms::Node
                  .published
                  .where(content_id: id)
                  .where(model: 'Article::EventDoc')
                  .order(:id)
                  .first
  end

  def tag_node
    return @tag_node if @tag_node
    @tag_node = Cms::Node
                .published
                .where(content_id: id)
                .where(model: 'Article::TagDoc')
                .order(:id)
                .first
  end
end
