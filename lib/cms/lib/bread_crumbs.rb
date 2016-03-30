# encoding: utf-8
class Cms::Lib::BreadCrumbs
  @crumbs = []
  def initialize(crumbs = [])
    @crumbs = crumbs if crumbs
  end

  attr_reader :crumbs

  def to_links(options = {})
    top_label = 'TOP'
    top_label = options[:top_label] unless options[:top_label].blank?

    h = ''
    @crumbs.each do |r|
      links = []
      r.first[0] = top_label if r.first[1] == Page.site.uri
      r.pop if r.last[1] =~ /index\.html$/
      r.each do |c|
        if c[0].class == Array
          l = []
          c.each do |c2|
            l << %(<a href="#{c2[1]}">#{c2[0]}</a>)
          end
          links << l.join("，")
        else
          links << %(<a href="#{c[1]}">#{c[0]}</a>)
        end
      end
      h << "<div>#{links.join(' &gt; ')}</div>"
    end
    h.html_safe
  end
end
