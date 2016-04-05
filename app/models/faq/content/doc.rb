# encoding: utf-8
class Faq::Content::Doc < Cms::Content
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
               .where(model: 'Faq::Doc')
               .order(:id)
               .first
  end

  def category_node
    return @category_node if @category_node
    @category_node = Cms::Node
                     .published
                     .where(content_id: id)
                     .where(model: 'Faq::Category')
                     .order(:id)
                     .first
  end

  def recent_node
    return @recent_node if @recent_node
    @recent_node = Cms::Node
                   .published
                   .where(content_id: id)
                   .where(model: 'Faq::RecentDoc')
                   .order(:id)
                   .first
  end

  def search_node
    return @search_node if @search_node
    @search_node = Cms::Node
                .published
                .where(content_id: id)
                .where(model: 'Faq::SearchDoc')
                .order(:id)
                .first
  end

  def tag_node
    return @tag_node if @tag_node
    @tag_node = Cms::Node
                .published
                .where(content_id: id)
                .where(model: 'Faq::TagDoc')
                .order(:id)
                .first
  end
end
