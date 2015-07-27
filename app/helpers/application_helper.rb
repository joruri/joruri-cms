# encoding: utf-8
module ApplicationHelper
  ## query string
  def query(params = nil)
    Util::Http::QueryString.get_query(params)
  end
  
  ## nl2br
  def br(str)
    str.gsub(/\r\n|\r|\n/, '<br />').html_safe
  end
  
  ## nl2br and escape
  def hbr(str)
    str = html_escape(str)
    str.gsub(/\r\n|\r|\n/, '<br />').html_safe
  end
  
  ## safe calling
  def safe(alt = nil, &block)
    begin
      yield
    rescue NoMethodError => e
      # nil判定を追加
      #if e.respond_to? :args and (e.args.nil? or (!e.args.blank? and e.args.first.nil?))
        alt
      #else
        # 原因がnilクラスへのアクセスでない場合は例外スロー
      #  raise
      #end
    end
  end
  
  ## paginates
  def paginate(items, options = {})
    return '' unless items
    defaults = {
      :params         => p,
      :previous_label => '前のページ',
      :next_label     => '次のページ',
      :link_separator => '<span class="separator"> | </span' + "\n" + '>'.html_safe
    }
    if request.mobile?
      defaults[:page_links]     = false
      defaults[:previous_label] = '<<*前へ'
      defaults[:next_label]     = '次へ#>>'
    end
    links = will_paginate(items, defaults.merge!(options))
    return links if links.blank?
    
    if Core.request_uri != Core.internal_uri
      links.gsub!(/href="(#{Core.internal_uri}[^"]+)/im) do |m|
        
        qp   = (m =~ /\?/) ? Rack::Utils.parse_query(m.gsub(/.*\?/, '').gsub(/&amp;/, '&')) : {}
        page = qp['page'].to_s =~ /^\d+$/ ? qp['page'].to_i : 1
        
        uri = m.gsub(/\?.*/, '')
        uri.gsub!(/^href="#{Core.internal_uri}/i, Page.uri)
        uri.gsub!(/\/(\?|$)/, "/index.html\\1")
        uri.gsub!(/\.p[0-9]+\.html/, ".html")
        uri.gsub!(/\.html/, ".p#{page}.html") if page > 1
        
        qs = qp.size > 0 ? "?" + qp.map{|k,v| "#{k}=#{v}"}.join("&") : ""
        %Q(href="#{uri.force_encoding("UTF-8")}#{qs.force_encoding("UTF-8")})
      end
    end
    if request.mobile?
      links.gsub!(/<a [^>]*?rel="prev( |")/) {|m| m.gsub(/<a /, '<a accesskey="*" ')}
      links.gsub!(/<a [^>]*?rel="next( |")/) {|m| m.gsub(/<a /, '<a accesskey="#" ')}
    end
    links.html_safe
  end
  
  ## number format
  def number_format(num)
    number_to_currency(num, :unit => '', :precision => 0)
  end

  ## emoji
  def emoji(name)
    require 'jpmobile'
    return Cms::Lib::Mobile::Emoji.convert(name, request.mobile)
  end
  
  ## furigana
  def ruby(str, ruby = nil)
    ruby = Page.ruby unless ruby
    return ruby == true ? Cms::Lib::Navi::Kana.convert(str) : str
  end
end
