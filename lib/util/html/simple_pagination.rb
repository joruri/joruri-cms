# encoding: utf-8
class Util::Html::SimplePagination
  attr_accessor :separator
  attr_accessor :prev_label, :prev_uri
  attr_accessor :next_label, :next_uri

  def initialize(params = {})
    @separator  = params[:separator] || '<span class="separator">|</span>'
    @prev_label = params[:prev_label] || "<前へ"
    @next_label = params[:next_label] || "次へ>"
    @prev_uri   = params[:prev_uri]
    @next_uri   = params[:next_uri]
  end

  def to_links(options = {})
    options[:class] ||= 'pagination'

    h = %(<div class="#{options[:class]}">)
    h += "\n"
    h += if prev_uri
           %(<a class="prev_page" href="#{prev_uri}">#{prev_label}</a>)
         else
           %(<span class="disabled prev_page">#{prev_label}</span>)
         end
    h += "\n" + separator + "\n" if separator
    h += if next_uri
           %(<a class="next_page" href="#{next_uri}">#{next_label}</a>)
         else
           %(<span class="disabled next_page">#{next_label}</span>)
         end
    h += "\n"
    h += %(</div>)
    h.html_safe
  end
end
