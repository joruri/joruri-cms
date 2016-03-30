# encoding: utf-8
module Article::DocHelper
  def article_doc_list(item, options = {})
    title_tag = options[:title_tag] || 'p'
    thumbnail = item.thumbnail_uri
    uri       = item.public_uri
    attr      = options[:attr] || item.date_and_unit
    new_mark  = item.new_mark ? '<span class="new">New</span>' : ''

    if options[:list_type].to_s == 'blog'
      h = ''
      h << %(<#{title_tag} class="title"><a href="#{uri}">#{h(item.title)}</a></#{title_tag}>)
      h << %(<a href="#{uri}"><img src="#{thumbnail}" alt="" /></a>) if thumbnail
      h << %(<div class="body">#{truncate(item.summary_body, length: 80)}</div>)
      h << attr.to_s
      return h.html_safe
    end

    %(#{link_to(item.title, item.public_uri)}#{new_mark}#{item.date_and_unit}).html_safe
  end
end
